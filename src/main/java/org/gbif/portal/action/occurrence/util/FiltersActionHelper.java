package org.gbif.portal.action.occurrence.util;

import org.gbif.api.model.Constants;
import org.gbif.api.model.checklistbank.NameUsage;
import org.gbif.api.model.checklistbank.NameUsageMatch;
import org.gbif.api.model.checklistbank.NameUsageMatch.MatchType;
import org.gbif.api.model.checklistbank.search.NameUsageSearchParameter;
import org.gbif.api.model.checklistbank.search.NameUsageSuggestRequest;
import org.gbif.api.model.checklistbank.search.NameUsageSuggestResult;
import org.gbif.api.model.common.search.SearchRequest;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.model.registry.Network;
import org.gbif.api.model.registry.search.DatasetSearchParameter;
import org.gbif.api.model.registry.search.DatasetSuggestRequest;
import org.gbif.api.model.registry.search.DatasetSuggestResult;
import org.gbif.api.service.checklistbank.NameUsageMatchingService;
import org.gbif.api.service.checklistbank.NameUsageSearchService;
import org.gbif.api.service.checklistbank.NameUsageService;
import org.gbif.api.service.occurrence.OccurrenceSearchService;
import org.gbif.api.service.registry.DatasetSearchService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.NetworkService;
import org.gbif.api.util.SearchTypeValidator;
import org.gbif.api.util.VocabularyUtils;
import org.gbif.api.vocabulary.BasisOfRecord;
import org.gbif.api.vocabulary.Continent;
import org.gbif.api.vocabulary.Country;
import org.gbif.api.vocabulary.DatasetType;
import org.gbif.api.vocabulary.MediaType;
import org.gbif.portal.model.SearchSuggestions;

import java.lang.reflect.InvocationTargetException;
import java.math.BigDecimal;
import java.text.DateFormatSymbols;
import java.util.Calendar;
import java.util.EnumSet;
import java.util.Enumeration;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.Nullable;
import javax.servlet.http.HttpServletRequest;

import com.google.common.base.Enums;
import com.google.common.base.Function;
import com.google.common.base.Optional;
import com.google.common.base.Preconditions;
import com.google.common.base.Predicate;
import com.google.common.base.Strings;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.google.common.primitives.Ints;
import com.google.inject.Inject;
import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.util.LocalizedTextUtil;
import org.apache.commons.beanutils.PropertyUtils;
import org.apache.commons.lang3.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.gbif.api.model.common.search.SearchConstants.QUERY_WILDCARD;

/**
 * Utility class for common operations of SearchAction and DownloadHomeAction.
 */
public class FiltersActionHelper {

  private final DatasetService datasetService;
  private final DatasetSearchService datasetSearchService;
  private final NameUsageService nameUsageService;
  private final NameUsageSearchService nameUsageSearchService;
  private final NameUsageMatchingService nameUsageMatchingService;
  private final OccurrenceSearchService occurrenceSearchService;
  private final NetworkService networkService;
  private static final int SUGGESTIONS_LIMIT = 10;

  private static final Pattern AMP_PATTERN = Pattern.compile("&");
  private static final Pattern START_POLYGON = Pattern.compile("POLYGON((",Pattern.LITERAL);
  private static final Pattern END_POLYGON = Pattern.compile("))",Pattern.LITERAL);
  private static final String QUOTES_REP = Matcher.quoteReplacement("");

  // Coordinate format
  private static final String BBOX_FMT = "FROM %s,%s TO %s,%s";

  private static final Logger LOG = LoggerFactory.getLogger(FiltersActionHelper.class);

  public static final String POLYGON_PATTERN = "POLYGON((%s))";

  public static final String TO_FMT = "To %s";

  public static final String GREATER_THAN_FMT = "Greater than %s";

  public static final String LESS_THAN_FMT = "Less than %s";

  public static final String FROM_FMT = "From %s";

  public static final String BETWEEN_FMT = "Between %s and %s";

  public static final String IS_FMT = "Is %s";

  public static final String YES = "Yes";

  public static final String NO = "No";

  // Utility function to get key value of a NameUsage
  private static final Function<NameUsageSuggestResult, String> NU_RESULT_KEY_GETTER =
    new Function<NameUsageSuggestResult, String>() {

      @Override
      public String apply(@Nullable NameUsageSuggestResult input) {
        Preconditions.checkNotNull(input);
        return input.getKey().toString();
      }
    };

  // Utility function to get key value of a Dataset
  private static final Function<DatasetSuggestResult, String> DS_RESULT_KEY_GETTER =
    new Function<DatasetSuggestResult, String>() {

      @Override
      public String apply(@Nullable DatasetSuggestResult input) {
        Preconditions.checkNotNull(input);
        return input.getKey().toString();
      }
    };

  private final Function<String, List<String>> suggestCollectorNames = new Function<String, List<String>>() {

    @Override
    public List<String> apply(String input) {
      return occurrenceSearchService.suggestRecordedBy(input, SUGGESTIONS_LIMIT);
    }
  };

  private final Function<String, List<String>> suggestRecordNumbers = new Function<String, List<String>>() {

    @Override
    public List<String> apply(String input) {
      return occurrenceSearchService.suggestRecordNumbers(input, SUGGESTIONS_LIMIT);
    }
  };

  private final Function<String, List<String>> suggestOccurrenceIds = new Function<String, List<String>>() {

    @Override
    public List<String> apply(String input) {
      return occurrenceSearchService.suggestOccurrenceIds(input, SUGGESTIONS_LIMIT);
    }
  };

  private final Function<String, List<String>> suggestCollectionCodes = new Function<String, List<String>>() {

    @Override
    public List<String> apply(String input) {
      return occurrenceSearchService.suggestCollectionCodes(input, SUGGESTIONS_LIMIT);
    }
  };

  private final Function<String, List<String>> suggestInstitutionCodes = new Function<String, List<String>>() {

    @Override
    public List<String> apply(String input) {
      return occurrenceSearchService.suggestInstitutionCodes(input, SUGGESTIONS_LIMIT);
    }
  };


  private final Function<String, List<String>> suggestCatalogNumbers = new Function<String, List<String>>() {

    @Override
    public List<String> apply(String input) {
      return occurrenceSearchService.suggestCatalogNumbers(input, SUGGESTIONS_LIMIT);
    }
  };

  private static final String GEOREFERENCING_LEGEND = "Georeferenced records only";

  private static final String SPATIAL_ISSUES_LEGEND = "With known coordinate issues";

  private static final String NOSPATIAL_ISSUES_LEGEND = "With NO known coordinate issues";

  private static final String METER = "m";

  private static final String ALL = "all";

  private static final String WILDCARD = "*";

  // List of official countries
  private static final Set<Country> COUNTRIES = Sets.immutableEnumSet(Sets.filter(
    Sets.newHashSet(Country.values()),
    new Predicate<Country>() {

      @Override
      public boolean apply(@Nullable Country country) {
        Preconditions.checkNotNull(country);
        return country.isOfficial();
      }
    }));

  /**
   * Constant that contains the prefix of a key to get a Basis of record name from the resource bundle file.
   */
  private static final String CONTINENT_KEY = "enum.continent.";

  /**
   * Constant that contains the prefix of a key to get a Basis of record name from the resource bundle file.
   */
  private static final String BASIS_OF_RECORD_KEY = "enum.basisofrecord.";


  /**
   * Constant that contains the prefix of a key to get a TypeStatus label from the resource bundle file.
   */
  private static final String TYPE_STATUS_KEY = "enum.typestatus.";


  /**
   * Constant that contains the prefix of a key to get a Media Type label from the resource bundle file.
   */
  private static final String MEDIA_TYPE_KEY = "enum.mediatype.";


  /**
   * Constant that contains the prefix of a key to get a OccurrenceIssue label from the resource bundle file.
   */
  private static final String OCCURRENCE_ISSUE_KEY = "enum.occurrenceissue.";

  @Inject
  public FiltersActionHelper(DatasetService datasetService, NameUsageService nameUsageService,
    NameUsageSearchService nameUsageSearchService, NameUsageMatchingService nameUsageMatchingService,
    DatasetSearchService datasetSearchService, NetworkService networkService,
    OccurrenceSearchService occurrenceSearchService) {
    this.datasetService = datasetService;
    this.nameUsageService = nameUsageService;
    this.nameUsageSearchService = nameUsageSearchService;
    this.nameUsageMatchingService = nameUsageMatchingService;
    this.datasetSearchService = datasetSearchService;
    this.networkService = networkService;
    this.occurrenceSearchService = occurrenceSearchService;
  }

  /**
   * @return the list of {@link BasisOfRecord} literals.
   */
  public static BasisOfRecord[] getBasisOfRecords() {
    return BasisOfRecord.values();
  }

  /**
   * @return the list of {@link Country} literals.
   */
  public static Set<Country> getCountries() {
    return COUNTRIES;
  }

  /**
   *
   * @param isoCode iso 2/3 country code
   * @return the title(name) of a country.
   */
  public static String getCountryTitle(String isoCode) {
    Country country = Country.fromIsoCode(isoCode);
    if (country != null) {
      return country.getTitle();
    }
    return isoCode;
  }

  /**
   * @return the list of {@link org.gbif.api.vocabulary.Continent} literals.
   */
  public static Continent[] getContinents() {
    return Continent.values();
  }

  /**
   * This value is used by occurrence filters to determine the maximum year that is allowed for the
   * OccurrenceSearchParamater.EVENT_DATE.
   * @return the current year
   */
  public static int getCurrentYear() {
    return Calendar.getInstance().get(Calendar.YEAR);
  }

  /**
   * Gets the Dataset title, the key parameter is returned if either the Dataset doesn't exists or it
   * doesn't have a title.
   * @param key  dataset UUID
   * @return dataset title
   */
  public String getDatasetTitle(String key) {
    try {
      Dataset dataset = datasetService.get(UUID.fromString(key));
      if (dataset != null && dataset.getTitle() != null) {
        return dataset.getTitle();
      }
    } catch (IllegalArgumentException e) {
      // no uuid
    }
    return key;
  }

  /**
   * Lookups for titles/names for filters.
   */
  public String getFilterTitle(String filterKey, String filterValue) {
    return getFilterTitle(filterKey,filterValue,false);
  }

  /**
   * Lookups titles and names for facets values.
   */
  public String getFacetFilterTitle(String filterKey, String filterValue) {
    return getFilterTitle(filterKey,filterValue,true);
  }

  /**
   * @param filterKey filter key/name
   * @param filterValue filter value
   * @return the displayable value of filter parameter.
   */
  private String getFilterTitle(String filterKey, String filterValue, boolean forFacets) {
    OccurrenceSearchParameter parameter =
      (OccurrenceSearchParameter) VocabularyUtils.lookupEnum(filterKey, OccurrenceSearchParameter.class);
    if (parameter != null) {
      if (WILDCARD.equals(filterValue)) {
        return ALL;
      } else if (parameter == OccurrenceSearchParameter.TAXON_KEY) {
        return StringEscapeUtils.escapeEcmaScript(getScientificName(filterValue));
      } else if (parameter == OccurrenceSearchParameter.BASIS_OF_RECORD) {
        return LocalizedTextUtil.findDefaultText(BASIS_OF_RECORD_KEY + filterValue, getLocale());
      } else if (parameter == OccurrenceSearchParameter.TYPE_STATUS) {
        return LocalizedTextUtil.findDefaultText(TYPE_STATUS_KEY + filterValue, getLocale());
      } else if (parameter == OccurrenceSearchParameter.MEDIA_TYPE) {
        return LocalizedTextUtil.findDefaultText(MEDIA_TYPE_KEY + getMediaTypeValue(filterValue), getLocale());
      } else if (parameter == OccurrenceSearchParameter.DATASET_KEY) {
        return StringEscapeUtils.escapeEcmaScript(getDatasetTitle(filterValue));
      } else if (parameter == OccurrenceSearchParameter.GEOMETRY) {
        return getGeometryTitle(filterValue);
      } else if (parameter == OccurrenceSearchParameter.HAS_COORDINATE) {
        return getGeoreferencedTitle(filterValue);
      } else if (parameter == OccurrenceSearchParameter.COUNTRY
                 || parameter == OccurrenceSearchParameter.PUBLISHING_COUNTRY) {
        return StringEscapeUtils.escapeEcmaScript(getCountryTitle(filterValue));
      } else if (parameter == OccurrenceSearchParameter.CONTINENT) {
        return LocalizedTextUtil.findDefaultText(CONTINENT_KEY + filterValue, getLocale());
      } else if (parameter == OccurrenceSearchParameter.DEPTH || parameter == OccurrenceSearchParameter.ELEVATION) {
        return forFacets ? filterValue : getRangeTitle(filterValue, METER);
      } else if (parameter == OccurrenceSearchParameter.EVENT_DATE
                 || parameter == OccurrenceSearchParameter.LAST_INTERPRETED) {
        return forFacets ? filterValue : getDateRangeTitle(filterValue);
      } else if (parameter == OccurrenceSearchParameter.YEAR) {
        return forFacets ? filterValue : getTemporalRangeTitle(filterValue);
      } else if (parameter == OccurrenceSearchParameter.MONTH) {
        return forFacets ? getMonthName(Integer.parseInt(filterValue)) : getMonthRangeTitle(filterValue);
      } else if (parameter == OccurrenceSearchParameter.HAS_GEOSPATIAL_ISSUE) {
        return getSpatialIssuesTitle(filterValue);
      } else if (parameter == OccurrenceSearchParameter.ISSUE) {
        return LocalizedTextUtil.findDefaultText(OCCURRENCE_ISSUE_KEY + filterValue, getLocale());
      } else if (parameter == OccurrenceSearchParameter.REPATRIATED) {
        return getRepatriatedTitle(filterValue);
      }
    }
    return filterValue;
  }

  /**
   * @return the enum name of the value string if it is a valid media type.
   * Note: this has to be done because MediaType values are not in uppercase, i.e.: StillImage, MovingImage and Sound.
   */
  public static String getMediaTypeValue(String value) {
    if (!WILDCARD.equals(value)) {
      final Enum<?> mediaType = VocabularyUtils.lookupEnum(value, MediaType.class);
      return mediaType == null ? value : mediaType.name();
    }
    return value;
  }

  /**
   * @return the title for the georeferenced filter.
   */
  public static String getGeoreferencedTitle(String value) {
    if (Boolean.parseBoolean(value)) {
      return GEOREFERENCING_LEGEND;
    } else {
      return "Non " + GEOREFERENCING_LEGEND;
    }
  }

  /**
   * @return the title for the repatriated  filter.
   */
  public static String getRepatriatedTitle(String value) {
    if (Boolean.parseBoolean(value)) {
      return YES;
    } else {
      return NO;
    }
  }

  /**
   * @param networkKey node key/UUID
   *
   * @return the title(name) of a node.
   */
  public String getNetworkTitle(String networkKey) {
    try {
      Network network = networkService.get(UUID.fromString(networkKey));
      return network.getTitle();
    } catch (Exception e) {
      return null;
    }
  }

  /**
   * If a name usage doesn't exist for that taxon key, the same key is returned.
   * @param taxonKey taxon key
   * @return the scientific name associated to the taxon key parameter.
   */
  public String getScientificName(String taxonKey) {
    Integer taxonKeyInt = Ints.tryParse(taxonKey);
    if (taxonKeyInt != null) {
      NameUsage nameUsage = nameUsageService.get(taxonKeyInt, null);
      if (nameUsage != null && nameUsage.getScientificName() != null) {
        return nameUsage.getScientificName();
      }
    }
    return taxonKey;
  }

  public static String getSpatialIssuesTitle(String value) {
    if (Boolean.parseBoolean(value)) {
      return SPATIAL_ISSUES_LEGEND;
    } else {
      return NOSPATIAL_ISSUES_LEGEND;
    }
  }


  /**
   * Searches for suggestion to all the CATALOG_NUMBER parameter values, if the input value has an exact match against
   * any suggestion, no suggestions are returned for that parameter.
   */
  public SearchSuggestions<String> processCatalogNumberSuggestions(HttpServletRequest request) {
    return processStringSuggestions(request, OccurrenceSearchParameter.CATALOG_NUMBER, suggestCatalogNumbers);
  }

  /**
   * Searches for suggestion to all the COLLECTION_CODE parameter values, if the input value has an exact match against
   * any suggestion, no suggestions are returned for that parameter.
   */
  public SearchSuggestions<String> processCollectionCodeSuggestions(HttpServletRequest request) {
    return processStringSuggestions(request, OccurrenceSearchParameter.COLLECTION_CODE, suggestCollectionCodes);
  }


  /**
   * Searches for suggestion to all the RECORDED_BY parameter values, if the input value has an exact match against
   * any suggestion, no suggestions are returned for that parameter.
   */
  public SearchSuggestions<String> processCollectorSuggestions(HttpServletRequest request) {
    return processStringSuggestions(request, OccurrenceSearchParameter.RECORDED_BY, suggestCollectorNames);
  }

  /**
   * Searches for suggestion to all the RECORD_NUMBER parameter values, if the input value has an exact match against
   * any suggestion, no suggestions are returned for that parameter.
   */
  public SearchSuggestions<String> processRecordNumbersSuggestions(HttpServletRequest request) {
    return processStringSuggestions(request, OccurrenceSearchParameter.RECORD_NUMBER, suggestRecordNumbers);
  }

  /**
   * Searches for suggestion to all the OCCURRENCE_ID parameter values, if the input value has an exact match against
   * any suggestion, no suggestions are returned for that parameter.
   */
  public SearchSuggestions<String> processOccurrenceIdSuggestions(HttpServletRequest request) {
    return processStringSuggestions(request, OccurrenceSearchParameter.OCCURRENCE_ID, suggestOccurrenceIds);
  }

  /**
   * Replace the DATASET_KEY parameters that have a scientific name that could be interpreted directly.
   */
  public static void processDatasetReplacements(SearchRequest<OccurrenceSearchParameter> searchRequest,
    SearchSuggestions<DatasetSuggestResult> suggestions) {
    processReplacements(searchRequest, suggestions, OccurrenceSearchParameter.DATASET_KEY, DS_RESULT_KEY_GETTER);

  }

  /**
   * Validates if a string (not an UUID) value was sent for the DATASET_KEY parameter.
   * If the value is not a number, a search by dataset title is performed and, if any, the available suggestions are
   * returned.
   */
  public SearchSuggestions<DatasetSuggestResult> processDatasetSuggestions(HttpServletRequest request) {
    String[] values = request.getParameterValues(OccurrenceSearchParameter.DATASET_KEY.name());
    SearchSuggestions<DatasetSuggestResult> searchSuggestions = new SearchSuggestions<DatasetSuggestResult>();
    if (values != null) { // there are not value
      // request instance is created here for future reuse
      DatasetSuggestRequest suggestRequest = new DatasetSuggestRequest();
      suggestRequest.setLimit(SUGGESTIONS_LIMIT);
      for (String value : values) {
        if (tryParseUUID(value) == null) { // Is not a integer
          suggestRequest.setQ(value);
          // By default only occurrence datasets are suggested
          suggestRequest.addParameter(DatasetSearchParameter.TYPE, DatasetType.OCCURRENCE);
          List<DatasetSuggestResult> suggestions = datasetSearchService.suggest(suggestRequest);
          // suggestions are stored in map: "parameter value" -> list of suggestions
          if (suggestions.size() == 1) {
            searchSuggestions.getReplacements().put(value, suggestions.get(0));
          } else {
            searchSuggestions.getSuggestions().put(value, suggestions);
          }
        }
      }
    }
    return searchSuggestions;
  }

  /**
   * Searches for suggestion to all the INSTITUTION_CODE parameter values, if the input value has an exact match against
   * any
   * suggestion, no suggestions are returned for that parameter.
   */
  public SearchSuggestions<String> processInstitutionCodeSuggestions(HttpServletRequest request) {
    return processStringSuggestions(request, OccurrenceSearchParameter.INSTITUTION_CODE, suggestInstitutionCodes);
  }

  /**
   * Replace the taxon_key parameters that have a scientific name that could be interpreted directly.
   */
  public void processNameUsageReplacements(SearchRequest<OccurrenceSearchParameter> searchRequest,
    SearchSuggestions<NameUsageSuggestResult> suggestions) {
    processReplacements(searchRequest, suggestions, OccurrenceSearchParameter.TAXON_KEY, NU_RESULT_KEY_GETTER);

  }

  /**
   * Validates if a string (not a number) value was sent for the TAXON_KEY parameter.
   * If the value is not a number, a search by scientific name is performed and, if any, the available suggestions are
   * returned.
   */
  public SearchSuggestions<NameUsageSuggestResult> processNameUsagesSuggestions(HttpServletRequest request) {
    String[] values = request.getParameterValues(OccurrenceSearchParameter.TAXON_KEY.name());
    SearchSuggestions<NameUsageSuggestResult> nameUsagesSuggestion = new SearchSuggestions<NameUsageSuggestResult>();
    if (values != null) { // there are not value
      // request instance is created here for future reuse
      NameUsageSuggestRequest suggestRequest = new NameUsageSuggestRequest();
      suggestRequest.setLimit(SUGGESTIONS_LIMIT);
      suggestRequest.addParameter(NameUsageSearchParameter.DATASET_KEY, Constants.NUB_DATASET_KEY.toString());
      for (String value : values) {
        if (Ints.tryParse(value) == null) { // Is not a integer
          NameUsageMatch nameUsageMatch = nameUsageMatchingService.match(value, null, null, true, true);
          boolean hasAlternatives =
            nameUsageMatch.getAlternatives() != null && !nameUsageMatch.getAlternatives().isEmpty();
          if (nameUsageMatch.getMatchType() == MatchType.NONE && !hasAlternatives) {
            suggestRequest.setQ(value);
            List<NameUsageSuggestResult> suggestions = nameUsageSearchService.suggest(suggestRequest);
            // suggestions are stored in map: "parameter value" -> list of suggestions
            nameUsagesSuggestion.getSuggestions().put(value, suggestions);
          } else if (nameUsageMatch.getMatchType() == MatchType.NONE && hasAlternatives) {
            nameUsagesSuggestion.getSuggestions().put(value, toNameUsageResult(nameUsageMatch.getAlternatives()));
          } else {
            NameUsageSuggestResult nameUsageSuggestResult = toNameUsageResult(nameUsageMatch);
            nameUsagesSuggestion.getReplacements().put(value, nameUsageSuggestResult);
          }
        }
      }
    }
    return nameUsagesSuggestion;
  }

  /**
   * Checks if the search parameter contains correct values.
   * The occurrence parameter in the EnumSey discarded are not validated.
   */
  public static List<ParameterValidationError<OccurrenceSearchParameter>> validateSearchParameters(HttpServletRequest request,
    EnumSet<OccurrenceSearchParameter> discardedParams) {
    List<ParameterValidationError<OccurrenceSearchParameter>> errors = Lists.newArrayList();
    Enumeration<String> params = request.getParameterNames();
    while (params.hasMoreElements()) {
      String param = params.nextElement();
      try {
        Optional<OccurrenceSearchParameter> occParam = Enums.getIfPresent(OccurrenceSearchParameter.class, param.toUpperCase());
        if (occParam.isPresent()) {
          for (String value : request.getParameterValues(param)) {
            try {
              if (!discardedParams.contains(occParam.get())) {
                // discarded parameters are not validated those could be an integer or a string
                if (occParam.get() == OccurrenceSearchParameter.GEOMETRY) {
                  String polygonValue = String.format(POLYGON_PATTERN, value);
                  SearchTypeValidator.validate(occParam.get(), polygonValue);
                } else {
                  SearchTypeValidator.validate(occParam.get(), value);
                }
              }
            } catch (IllegalArgumentException ex) {
              String newUrl = removeParamFromURL(request, param, value);
              errors.add(new ParameterValidationError<OccurrenceSearchParameter>(occParam.get(), value, ex, newUrl));
            }
          }
        }
      } catch (IllegalArgumentException e) {
        // ignore paging params for example
        LOG.error("Error validating parameters", e);
      }
    }
    return errors;
  }

  /**
   * Returns the displayable label/value of a range filter.
   */
  private static String getDateRangeTitle(String value) {
    String[] rangeValue = value.split(",");
    if (rangeValue.length == 2) {
      if (rangeValue[0].equals(QUERY_WILDCARD)) {
        return String.format(TO_FMT, rangeValue[1]);
      } else if (rangeValue[1].equals(QUERY_WILDCARD)) {
        return String.format(FROM_FMT, rangeValue[0]);
      } else {
        return String.format(BETWEEN_FMT, rangeValue[0], rangeValue[1]);
      }
    } else {
      return String.format(IS_FMT, value);
    }
  }

  /**
   * Returns the displayable label/value of geometry filter.
   */
  private static String getGeometryTitle(String value) {
    String[] coordinates = value.split(",");
    if (isRectangle(value)) {
      final String[] southMost = coordinates[1].split(" ");
      final String[] northMost = coordinates[3].split(" ");
      return String.format(BBOX_FMT, southMost[1], southMost[0], northMost[1], northMost[0]);
    } else {
      return coordinates[0] + "..." + coordinates[coordinates.length - 2];
    }
  }


  /**
   * Gets the locale from the current web context.
   */
  private Locale getLocale() {
    ActionContext ctx = ActionContext.getContext();
    if (ctx != null) {
      return ctx.getLocale();
    } else {
      if (LOG.isDebugEnabled()) {
        LOG.debug("Action context not initialized");
      }
      return null;
    }
  }

  /**
   * Gets the name of the month int parameter.
   */
  public String getMonthName(int month) {
    return DateFormatSymbols.getInstance(getLocale()).getMonths()[month - 1];
  }


  /**
   * Returns the displayable label/value of a range filter.
   */
  private String getMonthRangeTitle(String value) {
    String[] rangeValue = value.split(",");
    if (rangeValue.length == 2) {
      if (rangeValue[0].equals(QUERY_WILDCARD)) {
        return String.format(TO_FMT, getMonthName(Integer.parseInt(rangeValue[1])));
      } else if (rangeValue[1].equals(QUERY_WILDCARD)) {
        return String.format(FROM_FMT, getMonthName(Integer.parseInt(rangeValue[0])));
      } else {
        return String.format(BETWEEN_FMT, getMonthName(Integer.parseInt(rangeValue[0])),
          getMonthName(Integer.parseInt(rangeValue[1])));
      }
    } else {
      return String.format(IS_FMT, getMonthName(Integer.parseInt(value)));
    }
  }


  /**
   * Returns the displayable label/value of a range filter.
   */
  private static String getRangeTitle(String value, String unit) {
    final String[] rangeValue = value.split(",");
    if (rangeValue.length == 2) {
      if (rangeValue[0].equals(QUERY_WILDCARD)) {
        return String.format(LESS_THAN_FMT, rangeValue[1] + unit);
      } else if (rangeValue[1].equals(QUERY_WILDCARD)) {
        return String.format(GREATER_THAN_FMT, rangeValue[0] + unit);
      } else {
        return String.format(BETWEEN_FMT, rangeValue[0] + unit, rangeValue[1] + unit);
      }
    } else {
      return String.format(IS_FMT, value + unit);
    }
  }

  /**
   * Returns the displayable label/value of a range filter.
   */
  private static String getTemporalRangeTitle(String value) {
    String[] rangeValue = value.split(",");
    if (rangeValue.length == 2) {
      if (rangeValue[0].equals(QUERY_WILDCARD)) {
        return String.format(TO_FMT, rangeValue[1]);
      } else if (rangeValue[1].equals(QUERY_WILDCARD)) {
        return String.format(FROM_FMT, rangeValue[0]);
      } else {
        return String.format(BETWEEN_FMT, rangeValue[0], rangeValue[1]);
      }
    } else {
      return String.format(IS_FMT, value);
    }
  }

  /**
   * Validates if the list of coordinates forms a rectangle.
   */
  private static boolean isRectangle(String value) {

    String[] values =  END_POLYGON.matcher(START_POLYGON.matcher(value).replaceAll(QUOTES_REP)).replaceAll(QUOTES_REP)
      .split(",");
    if (values.length == 5) {
      String[] point1 = values[0].split(" ");
      String[] point2 = values[1].split(" ");
      String[] point3 = values[2].split(" ");
      String[] point4 = values[3].split(" ");

      final BigDecimal valX1 = BigDecimal.valueOf(Float.parseFloat(point1[0]) + Float.parseFloat(point3[0]));
      final BigDecimal valX2 = BigDecimal.valueOf(Float.parseFloat(point2[0]) + Float.parseFloat(point4[0]));
      final BigDecimal valY1 = BigDecimal.valueOf(Float.parseFloat(point1[1]) + Float.parseFloat(point3[1]));
      final BigDecimal valY2 = BigDecimal.valueOf(Float.parseFloat(point2[1]) + Float.parseFloat(point4[1]));

      return valX1.compareTo(valX2) == 0 && valY1.compareTo(valY2) == 0;
    }
    return false;
  }

  /**
   * Utility method to perform replacement of parameters in the searchRequest from the suggestions.replacement field.
   */
  private static <T> void processReplacements(
    SearchRequest<OccurrenceSearchParameter> searchRequest,
    SearchSuggestions<T> suggestions, OccurrenceSearchParameter occParameter, Function<T, String> identifierGetter) {
    if (suggestions.hasReplacements()) {
      List<String> paramValues =
        Lists.newArrayList(searchRequest.getParameters().get(occParameter));
      for (String paramValue : paramValues) {
        if (suggestions.getReplacements().containsKey(paramValue)) {
          searchRequest.getParameters().remove(occParameter, paramValue);
          searchRequest.addParameter(occParameter,
            identifierGetter.apply(suggestions.getReplacements().get(paramValue)));
        }
      }
    }
  }

  /**
   * Searches for suggestion to all the RECORDED_BY parameters, if the input value has an exact match against any
   * suggestion, no suggestions are returned for that parameter.
   */
  private static SearchSuggestions<String> processStringSuggestions(HttpServletRequest request,
    OccurrenceSearchParameter occParameter, Function<String, List<String>> suggestionsFunction) {
    String[] values = request.getParameterValues(occParameter.name());
    SearchSuggestions<String> searchSuggestions = new SearchSuggestions<String>();
    if (values != null) { // there are not value
      // request instance is created here for future reuse
      for (String value : values) {
        List<String> suggestions = suggestionsFunction.apply(value);
        if (!suggestions.contains(value)) {
          // suggestions are stored in map: "parameter value" -> list of suggestions
          searchSuggestions.getSuggestions().put(value, suggestions);
        }
      }
    }
    return searchSuggestions;
  }


  /**
   * Remove the parameter/value pair from the query string.
   */
  private static String removeParamFromURL(HttpServletRequest request, String param, String value) {
    String queryString = request.getQueryString().replaceAll("(&?)" + param + '=' + value, "");
    if (queryString.startsWith("&")) {
      queryString = AMP_PATTERN.matcher(queryString).replaceFirst("");
    }
    return Strings.isNullOrEmpty(queryString) ? request.getRequestURI() : request.getRequestURI() + '?'
      + queryString;
  }

  /**
   * Converts a list of NameUsageMatch into a list of NameUsageSearchResult.
   */
  private static List<NameUsageSuggestResult> toNameUsageResult(List<NameUsageMatch> nameUsageMatches) {
    List<NameUsageSuggestResult> suggestions = Lists.newArrayList();
    for (NameUsageMatch matchAlt : nameUsageMatches) {
      suggestions.add(toNameUsageResult(matchAlt));
    }
    return suggestions;
  }

  /**
   * Converts a NameUsageMatch into a NameUsageSearchResult.
   */
  private static NameUsageSuggestResult toNameUsageResult(NameUsageMatch nameUsageMatch) {
    NameUsageSuggestResult nameUsageSuggestResult = null;

    try {
      nameUsageSuggestResult = new NameUsageSuggestResult();
      PropertyUtils.copyProperties(nameUsageSuggestResult, nameUsageMatch);
      nameUsageSuggestResult.setKey(nameUsageMatch.getUsageKey());
    } catch (IllegalAccessException e) {
      LOG.error("Error converting NameUsageMatch to NameUsageSearchResult", e);
    } catch (InvocationTargetException e) {
      LOG.error("Error converting NameUsageMatch to NameUsageSearchResult", e);
    } catch (NoSuchMethodException e) {
      LOG.error("Error converting NameUsageMatch to NameUsageSearchResult", e);
    }

    return nameUsageSuggestResult;
  }


  /**
   * Try to parse a UUID, if an exception is caught null is returned.
   */
  private static UUID tryParseUUID(String value) {
    try {
      return UUID.fromString(value);
    } catch (Exception e) {
      return null;
    }
  }
}
