package org.gbif.portal.action.occurrence;

import org.gbif.api.model.Constants;
import org.gbif.api.model.checklistbank.search.NameUsageSuggestResult;
import org.gbif.api.model.occurrence.Occurrence;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.model.occurrence.search.OccurrenceSearchRequest;
import org.gbif.api.model.registry.search.DatasetSuggestResult;
import org.gbif.api.service.occurrence.OccurrenceSearchService;
import org.gbif.api.vocabulary.BasisOfRecord;
import org.gbif.api.vocabulary.Continent;
import org.gbif.api.vocabulary.Country;
import org.gbif.api.vocabulary.EstablishmentMeans;
import org.gbif.api.vocabulary.MediaType;
import org.gbif.api.vocabulary.OccurrenceIssue;
import org.gbif.api.vocabulary.TypeStatus;
import org.gbif.dwc.terms.DcTerm;
import org.gbif.dwc.terms.DwcTerm;
import org.gbif.portal.action.BaseFacetedSearchAction;
import org.gbif.portal.action.occurrence.util.FiltersActionHelper;
import org.gbif.portal.action.occurrence.util.ParameterValidationError;
import org.gbif.portal.model.FacetInstance;
import org.gbif.portal.model.OccurrenceTable;
import org.gbif.portal.model.SearchSuggestions;

import java.util.EnumSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.base.Joiner;
import com.google.common.base.MoreObjects;
import com.google.common.base.Strings;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Multimap;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.gbif.api.model.common.paging.PagingConstants.DEFAULT_PARAM_LIMIT;
import static org.gbif.api.model.common.paging.PagingConstants.DEFAULT_PARAM_OFFSET;

/**
 * Search action class for occurrence search page.
 */
public class SearchAction
  extends BaseFacetedSearchAction<Occurrence, OccurrenceSearchParameter, OccurrenceSearchRequest> {

  private static final long serialVersionUID = 4064512946598688405L;

  private static final int DEFAULT_SPELLCHECK_COUNT = 4;

  private static final Logger LOG = LoggerFactory.getLogger(SearchAction.class);

  // Message key in resource bundle
  private static final String MAXOFFSET_ERROR_KEY = "max.offset.error";

  // Name of the offset field, used to display error messages related to the offset parameter
  private static final String OFFSET_FIELD = "offset";

  private static final String RIGHTS_TERM = "rights";

  //Use to perform replacements of q parameter
  private static final String Q_REPLACEMENT = "q=";

  private static final Pattern WHITESPACE_PAT = Pattern.compile(" ", Pattern.LITERAL);
  private static final String URL_WHITESPACE = Matcher.quoteReplacement("\\+");

  private static final Set<OccurrenceIssue> OCCURRENCE_ISSUES = EnumSet.allOf(OccurrenceIssue.class);

  private static final EnumSet<OccurrenceSearchParameter> SUPPORTED_FACETS =
    EnumSet.of(OccurrenceSearchParameter.BASIS_OF_RECORD,
               OccurrenceSearchParameter.TYPE_STATUS,
               OccurrenceSearchParameter.DATASET_KEY,
               OccurrenceSearchParameter.COUNTRY,
               OccurrenceSearchParameter.MONTH,
               OccurrenceSearchParameter.YEAR);

  // List of parameters that should be excluded during the regular validation.
  // These parameters are excluded since they could contain String values that will be processed as suggestions.
  private static final EnumSet<OccurrenceSearchParameter> OCC_VALIDATION_DISCARDED =
    EnumSet.of(OccurrenceSearchParameter.TAXON_KEY, OccurrenceSearchParameter.DATASET_KEY);

  private static final Joiner COMMA_JOINER = Joiner.on(',').skipNulls();

  private final FiltersActionHelper filtersActionHelper;

  private SearchSuggestions<NameUsageSuggestResult> nameUsagesSuggestions;

  private SearchSuggestions<DatasetSuggestResult> datasetsSuggestions;

  private SearchSuggestions<String> collectorSuggestions;

  private SearchSuggestions<String> recordNumberSuggestions;

  private SearchSuggestions<String> catalogNumberSuggestions;

  private SearchSuggestions<String> institutionCodeSuggestions;

  private SearchSuggestions<String> collectionCodeSuggestions;

  private SearchSuggestions<String> occurrenceIdSuggestions;

  private List<ParameterValidationError<OccurrenceSearchParameter>> validationErrors = Lists.newArrayList();

  private OccurrenceTable table;

  //Use to replace the q parameter by spell check suggestions
  private Matcher qReplacePattern;

  @Inject
  public SearchAction(OccurrenceSearchService occurrenceSearchService, FiltersActionHelper filtersActionHelper) {
    super(occurrenceSearchService, OccurrenceSearchParameter.class,
          new OccurrenceSearchRequest(DEFAULT_PARAM_OFFSET, DEFAULT_PARAM_LIMIT));
    this.filtersActionHelper = filtersActionHelper;
  }

  /*
   * (non-Javadoc)
   * @see org.gbif.portal.action.BaseSearchAction#execute()
   */
  @Override
  public String execute() {
    // read filter parameters in order to have them available even when the search wasn't executed.
    readFilterParams();

    table = new OccurrenceTable(request, getSearchRequest());

    initSuggestions();

    if (getSearchRequest().getOffset() > getMaxAllowedOffset()) {
      addFieldError(OFFSET_FIELD,
                    getText(MAXOFFSET_ERROR_KEY,
                            new String[] {Long.toString(getSearchRequest().getOffset()),
                              getMaxAllowedOffset().toString()}));

      return SUCCESS;
    }

    // process taxon/scientific-name suggestions
    nameUsagesSuggestions = filtersActionHelper.processNameUsagesSuggestions(request);

    // process dataset title suggestions
    datasetsSuggestions = filtersActionHelper.processDatasetSuggestions(request);

    // replace known name usages
    filtersActionHelper.processNameUsageReplacements(searchRequest, nameUsagesSuggestions);
    // replace known datasets
    FiltersActionHelper.processDatasetReplacements(searchRequest, datasetsSuggestions);

    // Search is executed only if there aren't suggestions that need to be notified to the user
    if (!hasSuggestions() && validateSearchParameters()) {
      return executeSearch();
    }
    return SUCCESS;
  }

  /**
   * Utility method that executes the search.
   * Differs to the BaseSearchAction.execute() method in that this method doesn't execute the method
   * BaseSearchAction.readFilterParams().
   *
   * @return SUCCESS, throws an exception in case of error
   */
  public String executeSearch() {
    LOG.info("Search for [{}]", getQ());
    // default query parameters
    searchRequest.setQ(getQ());
    // Turn off highlighting for empty query strings
    searchRequest.setHighlight(!Strings.isNullOrEmpty(q));
    //Enable spell check
    searchRequest.setSpellCheck(true);
    searchRequest.setSpellCheckCount(DEFAULT_SPELLCHECK_COUNT);

    searchRequest.setMultiSelectFacets(false);

    if (getCfg().isOccurrenceFacetsEnabled()) {
      // add all available facets to the request
      for (OccurrenceSearchParameter facet : SUPPORTED_FACETS) {
        searchRequest.addFacets(facet);
        String facetOffset = request.getParameter(facet.name() + ".offset");
        if (facetOffset != null) {
          searchRequest.addFacetPage(facet,Integer.parseInt(facetOffset),DEFAULT_FACET_LIMIT);
        }
      }
    }
    // issues the search operation
    searchResponse = searchService.search(searchRequest);
    // Provide suggestions for catalog numbers and collector names
    provideSuggestions();

    LOG.debug("Search for [{}] returned {} results", getQ(), searchResponse.getCount());

    if (getCfg().isOccurrenceFacetsEnabled()) {
      // initializes the elements required by the UI
      initializeFacetsForUI();
      initSelectedFacetCounts();
      initMinCounts();
      lookupFacetTitles();
    }

    return SUCCESS;
  }

  /**
   * Utility function that sets facet titles.
   * The function uses a function parameter to accomplish this task.
   * The getTitleFunction could provide the actual communication with the service later to provide the required title.
   */
  protected void lookupFacetTitles() {
    // "cache"
    Map<String, String> names = Maps.newHashMap();
    // facet counts
    for (Map.Entry<OccurrenceSearchParameter, List<FacetInstance>> facetEntry : getFacetCounts().entrySet()) {
      for (int idx = 0; idx < facetEntry.getValue().size(); idx++) {
        FacetInstance c = facetEntry.getValue().get(idx);
        if (names.containsKey(c.getName())) {
          c.setTitle(names.get(c.getName()));
        } else {
          try {
            c.setTitle(filtersActionHelper.getFacetFilterTitle(facetEntry.getKey().name(), c.getName()));
            names.put(c.getName(), c.getTitle());
          } catch (Exception e) {
            LOG.warn("Cannot lookup {} title for {}", new Object[] {facetEntry.getKey().name(), c.getName(), e});
          }
        }
      }
    }
  }

  /**
   * @return the list of {@link org.gbif.api.vocabulary.BasisOfRecord} literals.
   */
  public BasisOfRecord[] getBasisOfRecords() {
    return FiltersActionHelper.getBasisOfRecords();
  }

  /**
   * @return the list of {@link org.gbif.api.vocabulary.EstablishmentMeans} literals.
   */
  public EstablishmentMeans[] getEstablishmentMeans() {
    return EstablishmentMeans.values();
  }

  /**
   * @return the list of {@link org.gbif.api.vocabulary.BasisOfRecord} literals.
   */
  public Continent[] getContinents() {
    return FiltersActionHelper.getContinents();
  }

  /**
   * @return the list of {@link org.gbif.api.vocabulary.TypeStatus} literals applicable for specimens only.
   */
  public List<TypeStatus> getTypeStatuses() {
    return TypeStatus.specimenTypeStatusList();
  }

  /**
   * @return the list of {@link org.gbif.api.vocabulary.MediaType} literals.
   */
  public MediaType[] getMediaTypes() {
    return MediaType.values();
  }

  /**
   * @return the catalogNumberSuggestions
   */
  public SearchSuggestions<String> getCatalogNumberSuggestions() {
    return catalogNumberSuggestions;
  }

  /**
   * @return the collectionCodeSuggestions
   */
  public SearchSuggestions<String> getCollectionCodeSuggestions() {
    return collectionCodeSuggestions;
  }

  /**
   * @return the collectorSuggestions
   */
  public SearchSuggestions<String> getCollectorSuggestions() {
    return collectorSuggestions;
  }

  public SearchSuggestions<String> getRecordNumberSuggestions() {
    return recordNumberSuggestions;
  }

  public SearchSuggestions<String> getOccurrenceIdSuggestions() {
    return occurrenceIdSuggestions;
  }

  /**
   * Returns the list of {@link Country} literals.
   */
  public Set<Country> getCountries() {
    return FiltersActionHelper.getCountries();
  }

  /**
   * Returns the list of {@link OccurrenceIssue} literals.
   */
  public Set<OccurrenceIssue> getOccurrenceIssues() {
    return OCCURRENCE_ISSUES;
  }

  /**
   * This value is used by occurrence filters to determine the maximum year that is allowed for the
   * OccurrenceSearchParamater.EVENT_DATE.
   *
   * @return the current year.
   */
  public int getCurrentYear() {
    return FiltersActionHelper.getCurrentYear();
  }

  /**
   * Suggestions for dataset title search.
   *
   * @return the datasetsSuggestions
   */
  public SearchSuggestions<DatasetSuggestResult> getDatasetsSuggestions() {
    return datasetsSuggestions;
  }

  /**
   * Gets the Dataset title, the key parameter is returned if either the Dataset doesn't exists or it
   * doesn't have a title.
   *
   * @param key dataset UUID
   */
  public String getDatasetTitle(String key) {
    return filtersActionHelper.getDatasetTitle(key);
  }

  // this method is only a convenience one exposing the request filters so the ftl templates dont need to be adapted
  public Multimap<OccurrenceSearchParameter, String> getFilters() {
    return searchRequest.getParameters();
  }

  /**
   * Gets the readable value of filter parameter.
   *
   * @param filterKey   filter key
   * @param filterValue filter value
   *
   * @return filter title, if exists, filter value otherwise
   */
  public String getFilterTitle(String filterKey, String filterValue) {
    if (!isSuggestion(filterValue)) {
      return MoreObjects.firstNonNull(filtersActionHelper.getFilterTitle(filterKey, filterValue),
                                      Strings.nullToEmpty(filterValue));
    }
    return Strings.nullToEmpty(filterValue);
  }

  /**
   * @return the institutionCodeSuggestions
   */
  public SearchSuggestions<String> getInstitutionCodeSuggestions() {
    return institutionCodeSuggestions;
  }

  /**
   * @return the maximum default offset.
   */
  public int getMaxOffset() {
    return getCfg().getMaxOccSearchOffset();
  }

  /**
   * Suggestions for scientific name search.
   *
   * @return the nameUsagesSuggestions
   */
  public SearchSuggestions<NameUsageSuggestResult> getNameUsagesSuggestions() {
    return nameUsagesSuggestions;
  }

  /**
   * Gets the title(name) of a node.
   *
   * @param networkKey node key/UUID
   *
   * @return network name
   */
  public String getNetworkTitle(String networkKey) {
    return filtersActionHelper.getNetworkTitle(networkKey);
  }

  /**
   * @return the NUB key value.
   */
  public String getNubTaxonomyKey() {
    return Constants.NUB_DATASET_KEY.toString();
  }

  public String getParameterErrors(String parameter) {
    return COMMA_JOINER.join(getFieldErrors().get(parameter));
  }

  /**
   * Gets the configuration of fields and information to display.
   *
   * @return the table
   */
  public OccurrenceTable getTable() {
    return table;
  }

  public List<ParameterValidationError<OccurrenceSearchParameter>> getValidationErrors() {
    return validationErrors;
  }

  /**
   * @return the enum name of the value parameter.
   */
  public String getMediaTypeValue(String value) {
    return FiltersActionHelper.getMediaTypeValue(value);
  }

  @Override
  public boolean hasErrors() {
    return super.hasErrors() || !validationErrors.isEmpty();
  }

  /**
   * Validates if there are parameters with errors.
   *
   * @param parameter parameter to be validated
   *
   * @return true if the parameter has errors, false otherwise
   */
  public boolean hasParameterErrors(String parameter) {
    return getFieldErrors().containsKey(parameter);
  }

  /**
   * @return true if there are suggestions available, false otherwise
   */
  public boolean hasSuggestions() {
    return nameUsagesSuggestions.hasSuggestions() || datasetsSuggestions.hasSuggestions();
  }

  /**
   * @return True if the download functionality should be shown, False otherwise
   */
  public boolean showDownload() {
    return searchResponse != null
           && (searchResponse.getCount() != null && searchResponse.getCount() > 0)
           && (getCfg().getMaxOccDowloadSize() < 0
               || searchResponse.getCount()
                  <= getCfg().getMaxOccDowloadSize())
           && !hasErrors()
           && !hasSuggestions();
  }

  public boolean isValidFullTextDownload() {
    return  Strings.isNullOrEmpty(getQ()) && searchResponse.getCount() <= getCfg().getMaxOccFullTextDowloadSize();
  }

  @Override
  protected String translateFilterValue(OccurrenceSearchParameter param, String value) {
    if (param == OccurrenceSearchParameter.GEOMETRY) {
      return String.format(FiltersActionHelper.POLYGON_PATTERN, value);
    }
    if (Enum.class.isAssignableFrom(param.type())) {
      return value.toUpperCase();
    }
    return value;
  }

  /**
   * @return the maximum offset allowed using the current limit parameter.
   */
  public Integer getMaxAllowedOffset() {
    return getCfg().getMaxOccSearchOffset() - getSearchRequest().getLimit();
  }

  /**
   * Initializes the suggestion objects with empty values.
   */
  private void initSuggestions() {
    nameUsagesSuggestions = new SearchSuggestions<NameUsageSuggestResult>();
    datasetsSuggestions = new SearchSuggestions<DatasetSuggestResult>();
    collectorSuggestions = new SearchSuggestions<String>();
    catalogNumberSuggestions = new SearchSuggestions<String>();
    institutionCodeSuggestions = new SearchSuggestions<String>();
    collectionCodeSuggestions = new SearchSuggestions<String>();
    recordNumberSuggestions = new SearchSuggestions<String>();
    occurrenceIdSuggestions = new SearchSuggestions<String>();
  }

  /**
   * @return True if the parameter is in any lists of suggestions, False otherwise
   */
  private boolean isSuggestion(String value) {
    return nameUsagesSuggestions.getSuggestions().containsKey(value) || datasetsSuggestions.getSuggestions()
      .containsKey(value);
  }

  /**
   * Provides post-search suggestions. The suggestions are provided only if the count of results id 0.
   */
  private void provideSuggestions() {
    if (searchResponse.getCount() == null || searchResponse.getCount() == 0) {
      if (searchRequest.getParameters().containsKey(OccurrenceSearchParameter.RECORDED_BY)) {
        collectorSuggestions = filtersActionHelper.processCollectorSuggestions(request);
      }
      if (searchRequest.getParameters().containsKey(OccurrenceSearchParameter.CATALOG_NUMBER)) {
        catalogNumberSuggestions = filtersActionHelper.processCatalogNumberSuggestions(request);
      }
      if (searchRequest.getParameters().containsKey(OccurrenceSearchParameter.COLLECTION_CODE)) {
        collectionCodeSuggestions = filtersActionHelper.processCatalogNumberSuggestions(request);
      }
      if (searchRequest.getParameters().containsKey(OccurrenceSearchParameter.INSTITUTION_CODE)) {
        institutionCodeSuggestions = filtersActionHelper.processCatalogNumberSuggestions(request);
      }
      if (searchRequest.getParameters().containsKey(OccurrenceSearchParameter.RECORD_NUMBER)) {
        recordNumberSuggestions = filtersActionHelper.processRecordNumbersSuggestions(request);
      }
      if (searchRequest.getParameters().containsKey(OccurrenceSearchParameter.OCCURRENCE_ID)) {
        occurrenceIdSuggestions = filtersActionHelper.processOccurrenceIdSuggestions(request);
      }
    }
  }

  /**
   * Process the occurrence search parameters to validate if the values are correct.
   * The list of errors is store in the "errors" field.
   *
   * @return True if no errors are present, False otherwise
   */
  private boolean validateSearchParameters() {
    validationErrors = FiltersActionHelper.validateSearchParameters(request, OCC_VALIDATION_DISCARDED);
    return validationErrors.isEmpty();
  }

  /**
   * Retrieve value for Term in interpreted fields map. Currently expecting only DwcTerm.
   *
   * @param term Term
   * @param occ  occurrence record
   *
   * @return value for Term in fields map, or null if it doesn't exist
   */
  public static String termValue(String term, Occurrence occ) {
    // special case for Dc.rights
    if (RIGHTS_TERM.equals(term)) {
      return occ.getVerbatimField(DcTerm.rights);
    }
    DwcTerm dwcTerm = DwcTerm.valueOf(term);
    if (dwcTerm != null && occ != null && occ.getVerbatimFields() != null) {
      return occ.getVerbatimField(dwcTerm);
    }
    return null;
  }

  public String replaceQParam(String value) {
    return qReplacePattern.replaceAll(Matcher.quoteReplacement(Q_REPLACEMENT + value));
  }

  public void setQ(String q){
    super.setQ(q);
    qReplacePattern = Pattern.compile(Q_REPLACEMENT + WHITESPACE_PAT.matcher(q).replaceAll(URL_WHITESPACE))
                      .matcher(getServletRequest().getQueryString());
  }

}
