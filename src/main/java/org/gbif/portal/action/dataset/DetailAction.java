/*
 * Copyright 2011 Global Biodiversity Information Facility (GBIF) Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and limitations under the
 * License.
 */
package org.gbif.portal.action.dataset;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.model.registry.Endpoint;
import org.gbif.api.model.registry.Network;
import org.gbif.api.model.registry.eml.geospatial.GeospatialCoverage;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.vocabulary.Country;
import org.gbif.api.vocabulary.EndpointType;
import org.gbif.api.vocabulary.Extension;
import org.gbif.api.vocabulary.Kingdom;
import org.gbif.api.vocabulary.Rank;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.annotation.Nullable;
import javax.validation.constraints.NotNull;

import com.google.common.base.Joiner;
import com.google.common.base.Preconditions;
import com.google.common.base.Strings;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.inject.Inject;

/**
 * Populates the model objects for the dataset detail page.
 */
@SuppressWarnings("serial")
public class DetailAction extends DatasetBaseAction {

  private static final List<Extension> EXTENSIONS = ImmutableList.copyOf(Extension.values());
  private static final List<Kingdom> KINGDOMS = ImmutableList.of(Kingdom.ANIMALIA, Kingdom.ARCHAEA, Kingdom.BACTERIA,
    Kingdom.CHROMISTA, Kingdom.FUNGI, Kingdom.PLANTAE, Kingdom.PROTOZOA, Kingdom.VIRUSES, Kingdom.INCERTAE_SEDIS);

  private static final Set<EndpointType> DATA_CODES = ImmutableSet.<EndpointType>builder()
    .add(EndpointType.BIOCASE).add(EndpointType.TAPIR).add(EndpointType.DIGIR).add(EndpointType.DIGIR_MANIS)
    .add(EndpointType.DWC_ARCHIVE).add(EndpointType.TCS_RDF).add(EndpointType.TCS_XML).add(EndpointType.WFS)
    .build();
  private static final Set<EndpointType> METADATA_CODES = ImmutableSet.<EndpointType>builder()
    .add(EndpointType.EML).add(EndpointType.OAI_PMH).build();

  // allows reg ex replacement of names in geographic descriptions (reuse the pattern for performance)
  private static final Map<String, Country> COUNTRY_MAP = Maps.newHashMap();
  private static final Pattern COUNTRY_REG_EX = Pattern.compile(countryTitleRegEx(), Pattern.CASE_INSENSITIVE);

  /**
   * Builds a regular expression from all the country names, to allow replacement as links.
   */
  private static String countryTitleRegEx() {
    ImmutableList.Builder<String> b = ImmutableList.builder();

    // variants for country title "The Democratic Republic of the Congo"
    List<String> dRCVariants = ImmutableList
      .of("Democratic Republic of the Congo", "Democratic Republic of Congo", "DR Congo", "DRC",
        "République démocratique du Congo", "RDC");

    // Fix for POR-2533 - makes sure "The Democratic Republic of the Congo" can still be matched to its variants
    for (String variant : dRCVariants) {
      b.add(variant);
      COUNTRY_MAP.put(variant.toLowerCase(), Country.CONGO_DEMOCRATIC_REPUBLIC);
    }

    for (Country c : Country.values()) {
      if (c==null || Strings.isNullOrEmpty(c.getTitle())) {
        continue;
      }
      b.add(c.getTitle());
      COUNTRY_MAP.put(c.getTitle().toLowerCase(), c);
    }
    return "\\b(" + Joiner.on("|").join(b.build()) + ")\\b";
  }

  private final List<Endpoint> links = Lists.newArrayList();
  private final List<Endpoint> dataLinks = Lists.newArrayList();
  private final List<Endpoint> metaLinks = Lists.newArrayList();
  private List<Network> networks;

  @Nullable
  private PagingResponse<Dataset> constituents;
  private boolean renderMaps = false; // flag controlling map article rendering or not

  private static final int PAGE_SIZE = 10;

  @Inject
  public DetailAction(DatasetService datasetService, CubeService occurrenceCubeService,
    DatasetMetricsService metricsService, OrganizationService organizationService) {
    super(datasetService, occurrenceCubeService, metricsService, organizationService);
  }

  @Override
  public String execute() {
    loadDetail();
    insertCountryLinks();
    populateLinks(member.getEndpoints());
    // only datasets with a key (internal) can have constituents
    if (id != null) {
      constituents = datasetService.listConstituents(id, new PagingRequest(0, PAGE_SIZE));
      super.loadCountWrappedDatasets(constituents);
    }

    // the map article is rendered only if the cube has indicated georeferenced records, or if there are
    // coverages that are not global (they don't really warrant visualizing).
    renderMaps = getNumGeoreferencedOccurrences() > 0;
    if (!renderMaps) {
      for (GeospatialCoverage gc : member.getGeographicCoverages()) {
        renderMaps = gc.getBoundingBox() != null && !gc.getBoundingBox().isGlobalCoverage();
        if (renderMaps) {
          break; // for speed
        }
      }
    }
    // get networks
    networks = datasetService.listNetworks(id);

    return SUCCESS;
  }

  /**
   * Will not be null following execute() invocation.
   * @return the constituents datasets
   */
  @Nullable
  public PagingResponse<Dataset> getConstituents() {
    return constituents;
  }

  @NotNull
  public List<Endpoint> getDataLinks() {
    return dataLinks;
  }

  /**
   * Exposed to allow easy access in freemarker.
   * @return all available extensions
   */
  public List<Extension> getExtensions() {
    return EXTENSIONS;
  }

  /**
   * Exposed to allow easy access in freemarker.
   * @return all available kingdoms
   */
  public List<Kingdom> getKingdoms() {
    return KINGDOMS;
  }

  @NotNull
  public List<Endpoint> getLinks() {
    return links;
  }

  @NotNull
  public List<Endpoint> getMetaLinks() {
    return metaLinks;
  }

  @Override
  @Nullable
  public Dataset getParentDataset() {
    return parentDataset;
  }

  /**
   * Exposed to allow easy access in freemarker.
   * @return list of Ranks sorted by counts
   */
  public List<Rank> getSortedMetricRanks() {
    List<Rank> sortedRanks = Lists.newArrayList(metrics.getCountByRank().keySet());
    Collections.sort(sortedRanks);
    return sortedRanks;
  }

  @NotNull
  public Map<String, String> getResourceBundleProperties() {
    return getResourceBundleProperties("enum.rank.");
  }

  public boolean isRenderMaps() {
    return renderMaps;
  }

  /**
   * Creates html links to country pages if country names are found.
   */
  private void insertCountryLinks() {
    final String countryUrl = getBaseUrl() + "/country/";

    // main description
    if (!Strings.isNullOrEmpty(getDataset().getDescription())) {
      Matcher m = COUNTRY_REG_EX.matcher(getDataset().getDescription());
      StringBuffer sb = new StringBuffer();
      while (m.find()) {
        Country c = COUNTRY_MAP.get(m.group(1).toLowerCase());
        String replacement;
        if (c != null) {
          replacement = "<a href='" + countryUrl + c.getIso2LetterCode() + "'>" + m.group(1) + "</a>";
        } else {
          replacement = m.group(1);
        }
        m.appendReplacement(sb, replacement);
      }
      m.appendTail(sb);
      getDataset().setDescription(sb.toString());
    }

    // spatial coverage
    for (GeospatialCoverage gc : getDataset().getGeographicCoverages()) {
      // There are not yet any links to the actual countries
      if (!Strings.isNullOrEmpty(gc.getDescription())) {
        Matcher m = COUNTRY_REG_EX.matcher(gc.getDescription());
        StringBuffer sb = new StringBuffer();
        while (m.find()) {
          Country c = COUNTRY_MAP.get(m.group(0).toLowerCase());
          String replacement = "<a href='" + countryUrl + c.getIso2LetterCode() + "'>" + m.group(1) + "</a>";
          m.appendReplacement(sb, replacement);
        }
        m.appendTail(sb);
        gc.setDescription(sb.toString());
      }
    }
  }

  /**
   * Populates the data, metadata and other links from the unified endpoint list.
   * @param endpoints list of endpoints/links
   */
  private void populateLinks(@NotNull List<Endpoint> endpoints) {
    Preconditions.checkNotNull(endpoints, "Enpoints cannot be null - expected empty list for no endpoints");
    dataLinks.clear(); // for safety
    metaLinks.clear();
    links.clear();
    for (Endpoint p : member.getEndpoints()) {
      if (DATA_CODES.contains(p.getType())) {
        dataLinks.add(p);
      } else if (METADATA_CODES.contains(p.getType())) {
        metaLinks.add(p);
      } else {
        links.add(p);
      }
    }
  }

  public List<Network> getNetworks() {
    return networks;
  }
}
