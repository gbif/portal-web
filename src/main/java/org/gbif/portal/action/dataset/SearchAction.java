/*
 * Copyright 2011 Global Biodiversity Information Facility (GBIF) Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and limitations under the
 * License.
 */
package org.gbif.portal.action.dataset;

import org.gbif.api.model.checklistbank.DatasetMetrics;
import org.gbif.api.model.metrics.cube.OccurrenceCube;
import org.gbif.api.model.metrics.cube.ReadBuilder;
import org.gbif.api.model.registry.search.DatasetSearchParameter;
import org.gbif.api.model.registry.search.DatasetSearchRequest;
import org.gbif.api.model.registry.search.DatasetSearchResult;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.DatasetSearchService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.util.VocabularyUtils;
import org.gbif.api.vocabulary.Country;
import org.gbif.api.vocabulary.DatasetType;
import org.gbif.portal.action.BaseFacetedSearchAction;
import org.gbif.portal.action.BaseSearchAction;

import java.io.IOException;
import java.io.StringReader;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.base.Function;
import com.google.common.base.Joiner;
import com.google.common.base.Strings;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.core.KeywordTokenizer;
import org.apache.lucene.analysis.miscellaneous.ASCIIFoldingFilter;
import org.apache.lucene.analysis.tokenattributes.CharTermAttribute;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("serial")
public class SearchAction
  extends BaseFacetedSearchAction<DatasetSearchResult, DatasetSearchParameter, DatasetSearchRequest> {

  private static final Logger LOG = LoggerFactory.getLogger(SearchAction.class);
  private final OrganizationService orgService;
  private Function<String, String> getOrgTitle;
  private Function<String, String> getDatasetTypeTitle;
  private Function<String, String> getCountryTitle;
  private final CubeService occurrenceCube;
  private final DatasetMetricsService checklistMetricsService;
  private static final Joiner TOKEN_JOINER = Joiner.on(' ').skipNulls();

  // Index of the record counts (occurrence or taxa)
  private final Map<UUID, Long> recordCounts = Maps.newHashMap();

  @Inject
  public SearchAction(DatasetSearchService datasetSearchService, OrganizationService orgService,
    CubeService occurrenceCube, DatasetMetricsService checklistMetricsService) {
    super(datasetSearchService, DatasetSearchParameter.class, new DatasetSearchRequest());
    this.orgService = orgService;
    this.occurrenceCube = occurrenceCube;
    this.checklistMetricsService = checklistMetricsService;
    initGetTitleFunctions();
  }

  /**
   * If the text matches query text, and doesn't contain any highlighting, the missing highlighting is added. Comparison
   * between the text and query text is case insensitive, and uses the whole query text (no stemming). If the first
   * comparison fails, the query text is converted to its ASCII equivalent, and a second comparison performed.
   * </br>
   * If the title text already contains highlighting, no action is taken and the unchanged .
   * </br>
   * Please note: this extraordinary measure is needed for a the full text field named dataset_title_ngram.
   * Solr supports highlighting for fixed ngram fields only (a fixed ngram is field with
   * minGramSize = maxGramSize) which is not the case for this field. For this reason, sometimes there is highlighting,
   * but for times when it's missing, this method will add the missing highlighting.
   * 
   * @param t dataset title
   * @param q search query text
   * @return dataset title updated with missing highlighting if necessary
   */
  public static String addMissingHighlighting(String t, String q) {
    if (!Strings.isNullOrEmpty(t) && !Strings.isNullOrEmpty(q) && !BaseSearchAction.HL_MATCHER.matcher(t).find()) {
      Pattern pattern = Pattern.compile(Pattern.quote(q), Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
      Matcher matcher = pattern.matcher(t);
      if (matcher.find()) {
        t = matcher.replaceAll(HL_PRE + q + HL_POST);
      } else {
        // try converting the query text to its ASCII equivalent, and check again. E.g. "straße" to "strasse"
        q = foldToAscii(q);
        pattern = Pattern.compile(Pattern.quote(q), Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
        matcher = pattern.matcher(t);
        if (matcher.find()) {
          t = matcher.replaceAll(HL_PRE + q + HL_POST);
        }
      }
    }
    return t;
  }

  /**
   * Checks if the dataset search result match (highlighted text) only occurred in the full text field.
   * This method goes through all highlighted fields that may be highlighted:
   * 
   * <pre>
   * <arr name="hl.fl">
   *   <str>dataset_title</str>
   *   <str>keyword</str>
   *   <str>iso_country_code</str>
   *   <str>owning_organization_title</str>
   *   <str>hosting_organization_title</str>
   *   <str>description</str>
   * </arr>
   * </pre>
   * 
   * If there is no highlighted text in any of these fields, it can be inferred that the match must have occurred in
   * the full text field.
   * </br>
   * If the query text was null, there can be no matching anyways so the method just returns false.
   * 
   * @param result DatasetSearchResult
   * @return whether a match only occurred on the full text field or not
   */
  public static boolean isFullTextMatchOnly(DatasetSearchResult result, String query) {
    if (Strings.isNullOrEmpty(query)) {
      return false;
    }
    final String keywords = result.getKeywords() == null ? "" : TOKEN_JOINER.join(result.getKeywords());
    if (isHighlightedText(result.getTitle())
      || isHighlightedText(result.getDescription())
      || isHighlightedText(result.getOwningOrganizationTitle())
      || isHighlightedText(result.getHostingOrganizationTitle())
      || isHighlightedText(keywords)) {

      return false;
    }
    // otherwise, it must have been a match against the full_text field
    return true;
  }

  /**
   * Uses the solr.ASCIIFoldingFilter to convert a string to its ASCII equivalent. See solr documentation for full
   * details.
   * </br>
   * When doing the conversion, this method mirrors GBIF's registry-solr schema configuration for
   * <fieldType name="text_auto_ngram">. For example, it uses the KeywordTokenizer that treats the entire string as a
   * single token, regardless of its content. See the solr documentation for more details.
   * </br>
   * This method is needed when checking if the query string matches the dataset title. For example, if the query
   * string is "straße", it won't match the dataset title "Schulhof Gymnasium Hürth Bonnstrasse" unless "straße" gets
   * converted to its ASCII equivalent "strasse".
   * 
   * @param q query string
   * @return query string converted to ASCII equivalent
   * @see org.gbif.portal.action.dataset.SearchAction#addMissingHighlighting(String, String)
   * @see org.apache.lucene.analysis.miscellaneous.ASCIIFoldingFilter
   * @see org.apache.lucene.analysis.core.KeywordTokenizer
   */
  protected static String foldToAscii(String q) {
    if (!Strings.isNullOrEmpty(q)) {
      ASCIIFoldingFilter filter = null;
      try {
        StringReader reader = new StringReader(q);
        TokenStream stream = new KeywordTokenizer(reader);
        filter = new ASCIIFoldingFilter(stream);
        CharTermAttribute termAtt = filter.addAttribute(CharTermAttribute.class);
        filter.reset();
        filter.incrementToken();
        // converted q to ASCII equivalent and return it
        return termAtt.toString();
      } catch (IOException e) {
        // swallow
      } finally {
        if (filter != null) {
          try {
            filter.end();
            filter.close();
          } catch (IOException e) {
            // swallow
          }
        }
      }
    }
    return q;
  }

  @Override
  public String execute() {
    super.execute();
    // replace organisation keys with real names
    lookupFacetTitles(DatasetSearchParameter.HOSTING_ORG, getOrgTitle);
    lookupFacetTitles(DatasetSearchParameter.OWNING_ORG, getOrgTitle);
    lookupFacetTitles(DatasetSearchParameter.TYPE, getDatasetTypeTitle);
    lookupFacetTitles(DatasetSearchParameter.PUBLISHING_COUNTRY, getCountryTitle);

    // populate counts
    for (DatasetSearchResult dsr : getSearchResponse().getResults()) {
      if (DatasetType.OCCURRENCE == dsr.getType()) {
        Long count = occurrenceCube.get(new ReadBuilder().at(OccurrenceCube.DATASET_KEY, dsr.getKey()));
        recordCounts.put(dsr.getKey(), count);
      } else if (DatasetType.CHECKLIST == dsr.getType()) {
        // Client response status 204 (Equal to no content) gets converted into NULL
        // See HttpErrorResponseInterceptor.java in gbif-common-ws for more information
        DatasetMetrics metrics = checklistMetricsService.get(dsr.getKey());
        if (metrics != null) {
          recordCounts.put(dsr.getKey(), Long.valueOf(metrics.getUsagesCount()));
        }
      }
    }


    return SUCCESS;
  }

  public Map<UUID, Long> getRecordCounts() {
    return recordCounts;
  }

  /**
   * Initializes the getTitle functions
   */
  private void initGetTitleFunctions() {
    getOrgTitle = new Function<String, String>() {

      @Override
      public String apply(String key) {
        if (!Strings.isNullOrEmpty(key)) {
          try {
            return orgService.get(UUID.fromString(key)).getTitle();
          } catch (Exception e) {
          }
        }
        return null;
      }
    };

    getDatasetTypeTitle = new Function<String, String>() {

      @Override
      public String apply(String name) {
        return getEnumTitle("datasettype", name);
      }
    };

    getCountryTitle = new Function<String, String>() {

      @Override
      public String apply(String name) {
        try {
          Country c = (Country) VocabularyUtils.lookupEnum(name, Country.class);
          return c.getTitle();

        } catch (IllegalArgumentException e) {
          return name;
        }
      }
    };
  }
}
