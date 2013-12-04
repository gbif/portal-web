/*
 * Copyright 2011 Global Biodiversity Information Facility (GBIF) Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and limitations under the
 * License.
 */
package org.gbif.portal.action;

import org.gbif.api.model.common.search.Facet;
import org.gbif.api.model.common.search.FacetedSearchRequest;
import org.gbif.api.model.common.search.SearchParameter;
import org.gbif.api.service.common.SearchService;
import org.gbif.portal.model.FacetInstance;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.google.common.base.Function;
import com.google.common.base.Splitter;
import com.google.common.base.Strings;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Provides the basic structure and functionality for: free text search, paginated navigation and faceting navigation.
 * Besides the inherited functionality from {@link BaseSearchAction} this class provides several features:
 * - Execution of the search request using an instance of {@link SearchService}.
 * - Holds the user selected values of a facet.
 * - Provides the required information for displaying the facet counts.
 * 
 * @param <T> type of the results content
 * @param <P> the search parameter enum
 * @param <R> the request type
 */
public abstract class BaseFacetedSearchAction<T, P extends Enum<?> & SearchParameter, R extends FacetedSearchRequest<P>>
  extends BaseSearchAction<T, P, R> {

  private static final Logger LOG = LoggerFactory.getLogger(BaseFacetedSearchAction.class);
  private static final long serialVersionUID = -1573017190241712345L;
  private static final Splitter querySplitter = Splitter.on("&").omitEmptyStrings();
  private static final Splitter paramSplitter = Splitter.on("=");

  // network entity title lookup by their uuid key. Can be used for organizations, networks, nodes or datasets
  protected Map<UUID, String> titles = Maps.newHashMap();

  private final Map<P, List<FacetInstance>> facetCounts = Maps.newHashMap();
  private final Map<P, Long> facetMinimumCount = Maps.newHashMap();
  private final Map<P, List<FacetInstance>> selectedFacetCounts = Maps.newHashMap();
  /**
   * This constant restricts the maximum number of facet results to be displayed
   */
  private static final int MAX_FACETS = 5;

  /**
   * Default constructor for this class.
   * 
   * @param searchService an instance of search service
   * @param searchType the type of the {@link Enum} used for search parameters & facets
   * @param request a new, default search request
   */
  protected BaseFacetedSearchAction(SearchService<T, P, R> searchService, Class<P> searchType, R request) {
    super(searchService, searchType, request);
  }

  /**
   * Adds facets to the search before it gets executed and initializes the facets to be displayed in the user interface.
   */
  @Override
  public String execute() {
    searchRequest.setMultiSelectFacets(true);
    // add all available facets to the request
    for (P fEnum : searchType.getEnumConstants()) {
      searchRequest.addFacets(fEnum);
    }
    // execute search
    final String result = super.execute();
    // initializes the elements required by the UI
    initializeFacetsForUI();
    initSelectedFacetCounts();
    initMinCounts();
    return result;
  }

  /**
   * Translates current url query parameter values via the translateFacetValue method.
   * 
   * @return current url with translated values
   */
  @Override
  public String getCurrentUrl() {
    StringBuffer currentUrl = request.getRequestURL();
    if (request.getQueryString() != null) {
      boolean first = true;
      for (String p : querySplitter.split(request.getQueryString())) {
        Iterator<String> kvIter = paramSplitter.split(p).iterator();
        // lowercase to handle URL hacking gracefully (http://dev.gbif.org/issues/browse/POR-522)
        String key = kvIter.next().toLowerCase();
        if (first) {
          currentUrl.append("?");
        } else {
          currentUrl.append("&");
        }
        if (kvIter.hasNext()) { // parameter could have no value
          String val = kvIter.next();
          // potentially translate facet values
          P facet = getSearchParam(key);
          if (facet != null) {
            val = translateFilterValue(facet, val);
          }
          currentUrl.append(key);
          currentUrl.append("=");
          currentUrl.append(val);
        } else {
          currentUrl.append(key);
        }
        first = false;
      }
    }
    return currentUrl.toString();
  }

  /**
   * Holds the facet count information retrieved after each search operation.
   * For accessing this field the user interface should be able to referencing map data types.
   * An example of usage of this field could be:
   * <#list facetCounts['RANK'] as count>
   * <option value="${count.name}">${count.name}-(${count.count})</option>
   * </#list>
   * In the previous example the selected elements of a "select" element will be populated by using the list of
   * counts of the facet 'RANK'.
   * 
   * @return the facetCounts
   */
  public Map<P, List<FacetInstance>> getFacetCounts() {
    return facetCounts;
  }

  public Map<P, Long> getFacetMinimumCount() {
    return facetMinimumCount;
  }

  public int getMaxFacets() {
    return MAX_FACETS;
  }

  /**
   * Gets the facet counts that are part of the current search request filter.
   * Used in the facet UI.
   * 
   * @return the selected facet counts if any
   */
  public Map<P, List<FacetInstance>> getSelectedFacetCounts() {
    return selectedFacetCounts;
  }

  public Map<UUID, String> getTitles() {
    return titles;
  }

  protected String getEnumTitle(String resourceEntry, String value) {
    if (Strings.isNullOrEmpty(value)) {
      return null;
    }
    return getText("enum." + resourceEntry + "." + value.toUpperCase());
  }

  /**
   * Utility function that sets facet titles.
   * The function uses a function parameter to accomplish this task.
   * The getTitleFunction could provide the actual communication with the service later to provide the required title.
   * 
   * @param facet the facet
   * @param getTitleFunction function that returns title using a facet name
   */
  protected void lookupFacetTitles(P facet, Function<String, String> getTitleFunction) {
    // "cache"
    Map<String, String> names = Maps.newHashMap();
    // facet counts
    if (facetCounts.containsKey(facet)) {
      for (int idx = 0; idx < facetCounts.get(facet).size(); idx++) {
        FacetInstance c = getFacetCounts().get(facet).get(idx);
        if (names.containsKey(c.getName())) {
          c.setTitle(names.get(c.getName()));
        } else {
          try {
            c.setTitle(getTitleFunction.apply(c.getName()));
            names.put(c.getName(), c.getTitle());
          } catch (Exception e) {
            LOG.warn("Cannot lookup {} title for {}", new Object[] {facet.name(), c.getName(), e});
          }
        }
      }
    }
  }

  /**
   * Searches for facetInstance.name in the list of FacetInstances.
   * 
   * @param facet search parameter to find the value in
   * @param name facet name to find, case insensitive
   * @return the existing facet instance from the counts or null
   */
  private FacetInstance findFacetInstanceByName(P facet, String name) {
    List<FacetInstance> fis = facetCounts.get(facet);
    if (fis != null) {
      for (FacetInstance fi : fis) {
        if (fi.getName() != null && fi.getName().equalsIgnoreCase(name)) {
          return fi;
        }
      }
    }
    return null;
  }

  /**
   * By using the response object, this method initializes the facetCounts field.
   * If the response object contains facets, iterates over the facets for copying the count information into the
   * facetCounts (see {@link Facet.Count}) field.
   */
  private void initializeFacetsForUI() {
    if (searchResponse!=null && searchResponse.getFacets() != null && !searchResponse.getFacets().isEmpty()) {
      // there are facets in the response
      for (Facet<P> facet : searchResponse.getFacets()) {
        if (facet.getCounts() != null) {// the facet.Count are stored in the facetCounts field
          // facetFilters.put(facet.getField(), toFacetInstance(facet.getCounts()));
          facetCounts.put(facet.getField(), toFacetInstance(facet.getCounts()));
        }
      }
    }
  }

  private void initMinCounts() {
    if (searchResponse!=null && !searchRequest.getParameters().isEmpty()) {
      // calculate the minimum count for each facet
      for (Facet<P> facet : searchResponse.getFacets()) {
        Long min = null;
        for (Facet.Count cnt : facet.getCounts()) {
          if (cnt.getCount() != null && (min == null || cnt.getCount() < min)) {
            min = cnt.getCount();
          }
        }
        facetMinimumCount.put(facet.getField(), min);
      }
    }
  }

  private void initSelectedFacetCounts() {
    if (!searchRequest.getParameters().isEmpty()) {
      // convert request filters into facets instances
      for (P facet : searchRequest.getParameters().keySet()) {
        selectedFacetCounts.put(facet, Lists.<FacetInstance>newArrayList());
        for (String filterValue : searchRequest.getParameters().get(facet)) {
          if (StringUtils.trimToNull(filterValue) != null) {
            FacetInstance facetInstance = findFacetInstanceByName(facet, filterValue);
            if (facetInstance == null) {
              facetInstance = new FacetInstance(filterValue);
              facetInstance.setCount(null);
              // also add them to the list of all counts so we will lookup titles
              if (!facetCounts.containsKey(facet)) {
                facetCounts.put(facet, Lists.<FacetInstance>newArrayList());
              }
              facetCounts.get(facet).add(facetInstance);
            }
            selectedFacetCounts.get(facet).add(facetInstance);
          }
        }
      }
    }
  }

  private List<FacetInstance> toFacetInstance(List<Facet.Count> counts) {
    List<FacetInstance> instances = Lists.newArrayList();
    for (Facet.Count c : counts) {
      // only show counts with at least 1 matching record
      if (c.getCount() > 0) {
        instances.add(new FacetInstance(c));
      }
    }
    return instances;
  }
}
