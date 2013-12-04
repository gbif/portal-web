package org.gbif.portal.action.occurrence;

import org.gbif.api.model.Constants;
import org.gbif.api.model.checklistbank.search.NameUsageSearchResult;
import org.gbif.api.model.occurrence.Occurrence;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.model.occurrence.search.OccurrenceSearchRequest;
import org.gbif.api.model.registry.search.DatasetSearchResult;
import org.gbif.api.service.occurrence.OccurrenceSearchService;
import org.gbif.api.vocabulary.BasisOfRecord;
import org.gbif.api.vocabulary.Country;
import org.gbif.portal.action.BaseSearchAction;
import org.gbif.portal.action.occurrence.util.FiltersActionHelper;
import org.gbif.portal.action.occurrence.util.ParameterValidationError;
import org.gbif.portal.model.OccurrenceTable;
import org.gbif.portal.model.SearchSuggestions;

import java.util.EnumSet;
import java.util.List;
import java.util.Set;

import com.google.common.base.Joiner;
import com.google.common.base.Strings;
import com.google.common.collect.Lists;
import com.google.common.collect.Multimap;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.gbif.api.model.common.paging.PagingConstants.DEFAULT_PARAM_LIMIT;
import static org.gbif.api.model.common.paging.PagingConstants.DEFAULT_PARAM_OFFSET;

/**
 * Search action class for occurrence search page.
 */
public class SearchAction extends BaseSearchAction<Occurrence, OccurrenceSearchParameter, OccurrenceSearchRequest> {

  private static final long serialVersionUID = 4064512946598688405L;

  private static final Logger LOG = LoggerFactory.getLogger(SearchAction.class);

  private final FiltersActionHelper filtersActionHelper;

  private SearchSuggestions<NameUsageSearchResult> nameUsagesSuggestions;

  private SearchSuggestions<DatasetSearchResult> datasetsSuggestions;

  private SearchSuggestions<String> collectorSuggestions;

  private SearchSuggestions<String> catalogNumberSuggestions;

  private SearchSuggestions<String> institutionCodeSuggestions;

  private SearchSuggestions<String> collectionCodeSuggestions;

  private List<ParameterValidationError<OccurrenceSearchParameter>> validationErrors = Lists.newArrayList();

  // Message key in resource bundle
  private static final String MAXOFFSET_ERROR_KEY = "max.offset.error";

  // Name of the offset field, used to display error messages related to the offset parameter
  private static final String OFFSET_FIELD = "offset";


  // List of parameters that should be excluded during the regular validation.
  // These parameters are excluded since they could contain String values that will be processed as suggestions.
  private static final EnumSet<OccurrenceSearchParameter> OCC_VALIDATION_DISCARDED = EnumSet.of(
    OccurrenceSearchParameter.TAXON_KEY, OccurrenceSearchParameter.DATASET_KEY);

  private OccurrenceTable table;


  @Inject
  public SearchAction(OccurrenceSearchService occurrenceSearchService, FiltersActionHelper filtersActionHelper) {
    super(occurrenceSearchService, OccurrenceSearchParameter.class, new OccurrenceSearchRequest(DEFAULT_PARAM_OFFSET,
      DEFAULT_PARAM_LIMIT));
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
      addFieldError(
        OFFSET_FIELD,
        getText(MAXOFFSET_ERROR_KEY,
          new String[] {Long.toString(getSearchRequest().getOffset()), getMaxAllowedOffset().toString()}));

      return SUCCESS;
    }

    // process taxon/scientific-name suggestions
    nameUsagesSuggestions = filtersActionHelper.processNameUsagesSuggestions(request);

    // process dataset title suggestions
    datasetsSuggestions = filtersActionHelper.processDatasetSuggestions(request);

    // replace known name usages
    filtersActionHelper.processNameUsageReplacements(searchRequest, nameUsagesSuggestions);
    // replace known datasets
    filtersActionHelper.processDatasetReplacements(searchRequest, datasetsSuggestions);

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
   */
  public String executeSearch() {
    LOG.info("Search for [{}]", getQ());
    // default query parameters
    searchRequest.setQ(getQ());
    // Turn off highlighting for empty query strings
    searchRequest.setHighlight(!Strings.isNullOrEmpty(q));
    // issues the search operation
    searchResponse = searchService.search(searchRequest);

    // Provide suggestions for catalog numbers and collector names
    provideSuggestions();

    LOG.debug("Search for [{}] returned {} results", getQ(), searchResponse.getCount());
    return SUCCESS;
  }

  /**
   * Returns the list of {@link BasisOfRecord} literals.
   */
  public BasisOfRecord[] getBasisOfRecords() {
    return filtersActionHelper.getBasisOfRecords();
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

  /**
   * Returns the list of {@link Country} literals.
   */
  public Set<Country> getCountries() {
    return filtersActionHelper.getCountries();
  }


  /**
   * Gets the current year.
   * This value is used by occurrence filters to determine the maximum year that is allowed for the
   * OccurrenceSearchParamater.DATE.
   */
  public int getCurrentYear() {
    return filtersActionHelper.getCurrentYear();
  }

  /**
   * Suggestions for dataset title search.
   * 
   * @return the datasetsSuggestions
   */
  public SearchSuggestions<DatasetSearchResult> getDatasetsSuggestions() {
    return datasetsSuggestions;
  }


  /**
   * Gets the Dataset title, the key parameter is returned if either the Dataset doesn't exists or it
   * doesn't have a title.
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
   */
  public String getFilterTitle(String filterKey, String filterValue) {
    if (!isSuggestion(filterValue)) {
      return filtersActionHelper.getFilterTitle(filterKey, filterValue);
    }
    return filterValue;
  }


  /**
   * @return the institutionCodeSuggestions
   */
  public SearchSuggestions<String> getInstitutionCodeSuggestions() {
    return institutionCodeSuggestions;
  }

  /**
   * Return the maximum default offset.
   */
  public int getMaxOffset() {
    return getCfg().getMaxOccSearchOffset();
  }

  /**
   * Suggestions for scientific name search.
   * 
   * @return the nameUsagesSuggestions
   */
  public SearchSuggestions<NameUsageSearchResult> getNameUsagesSuggestions() {
    return nameUsagesSuggestions;
  }

  /**
   * Gets the title(name) of a node.
   * 
   * @param networkKey node key/UUID
   */
  public String getNetworkTitle(String networkKey) {
    return filtersActionHelper.getNetworkTitle(networkKey);
  }

  /**
   * Gets the NUB key value.
   */
  public String getNubTaxonomyKey() {
    return Constants.NUB_DATASET_KEY.toString();
  }

  public String getParameterErrors(String parameter) {
    Joiner COMMA_JOINER = Joiner.on(',').skipNulls();
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

  @Override
  public boolean hasErrors() {
    return super.hasErrors() || !validationErrors.isEmpty();
  }


  public boolean hasParameterErrors(String parameter) {
    return (getFieldErrors().containsKey(parameter));
  }

  /**
   * Checks if there are suggestions available.
   */
  public boolean hasSuggestions() {
    return nameUsagesSuggestions.hasSuggestions() || datasetsSuggestions.hasSuggestions();
  }

  /**
   * Validates if the download functionality should be shown.
   */
  public boolean showDownload() {
    return searchResponse != null && searchResponse.getCount() > 0
      && (getCfg().getMaxOccDowloadSize() < 0 || searchResponse.getCount() <= getCfg().getMaxOccDowloadSize())
      && !hasErrors() && !hasSuggestions();
  }

  @Override
  protected String translateFilterValue(OccurrenceSearchParameter param, String value) {
    if (param == OccurrenceSearchParameter.GEOMETRY) {
      return String.format(FiltersActionHelper.POLYGON_PATTERN, value);
    }
    return value;
  }

  /**
   * Calculates the maximum offset allowed using the current limit parameter.
   */
  public Integer getMaxAllowedOffset() {
    return getCfg().getMaxOccSearchOffset() - getSearchRequest().getLimit();
  }

  /**
   * Initializes the suggestion objects with empty values.
   */
  private void initSuggestions() {
    nameUsagesSuggestions = new SearchSuggestions<NameUsageSearchResult>();
    datasetsSuggestions = new SearchSuggestions<DatasetSearchResult>();
    collectorSuggestions = new SearchSuggestions<String>();
    catalogNumberSuggestions = new SearchSuggestions<String>();
    institutionCodeSuggestions = new SearchSuggestions<String>();
    collectionCodeSuggestions = new SearchSuggestions<String>();
  }

  /**
   * Checks if the parameter is in any lists of suggestions.
   */
  private boolean isSuggestion(String value) {
    return nameUsagesSuggestions.getSuggestions().containsKey(value)
      || datasetsSuggestions.getSuggestions().containsKey(value);
  }

  /**
   * Provides post-search suggestions. The suggestions are provided only if the count of results id 0.
   */
  private void provideSuggestions() {
    if (searchResponse.getCount() == 0) {
      if (searchRequest.getParameters().containsKey(OccurrenceSearchParameter.COLLECTOR_NAME)) {
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
    }
  }

  /**
   * Process the occurrence search parameters to validate if the values are correct.
   * The list of errors is store in the "errors" field.
   */
  private boolean validateSearchParameters() {
    validationErrors = filtersActionHelper.validateSearchParameters(request, OCC_VALIDATION_DISCARDED);
    return validationErrors.isEmpty();
  }
}
