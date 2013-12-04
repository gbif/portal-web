package org.gbif.portal.model;


import org.gbif.api.model.common.search.SearchRequest;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;

import java.util.EnumSet;

import javax.servlet.http.HttpServletRequest;

import com.google.common.base.Enums;
import com.google.common.base.Optional;

/**
 * Class that represents the configuration for the HTML table shown in the occurrence search page.
 */
public class OccurrenceTable {

  /**
   * Enum that represents the visible columns in the occurrence page.
   */
  public static enum OccurrenceColumn {
    SUMMARY, LOCATION, BASIS_OF_RECORD, DATE;
  }

  /**
   * Enum that represents the visible information of the summary column in the occurrence page.
   */
  public static enum OccurrenceSummaryField {
    OCCURRENCE_KEY, CATALOG_NUMBER, COLLECTION_CODE, COLLECTOR_NAME, INSTITUTION, SCIENTIFIC_NAME, DATASET, MODIFIED;
  }

  private static final OccurrenceSearchParameter[] OCC_LOCATION_PARAMS = new OccurrenceSearchParameter[] {
    OccurrenceSearchParameter.ALTITUDE, OccurrenceSearchParameter.DEPTH,
    OccurrenceSearchParameter.LATITUDE, OccurrenceSearchParameter.LONGITUDE, OccurrenceSearchParameter.GEOMETRY,
    OccurrenceSearchParameter.GEOREFERENCED, OccurrenceSearchParameter.COUNTRY};

  private static final OccurrenceSearchParameter[] OCC_DATE_PARAMS = new OccurrenceSearchParameter[] {
    OccurrenceSearchParameter.MONTH, OccurrenceSearchParameter.YEAR};

  // Default list of summary fields
  private static EnumSet<OccurrenceSummaryField> defaulSummaryFields = EnumSet.of(
    OccurrenceSummaryField.OCCURRENCE_KEY,
    OccurrenceSummaryField.CATALOG_NUMBER, OccurrenceSummaryField.SCIENTIFIC_NAME,
    OccurrenceSummaryField.DATASET);


  // Columns HTTP parameter
  private static final String COLUMNS_PARAM = "columns";

  // summary fields HTTP parameter
  private static final String SUMMARY_FIELDS_PARAM = "summary";

  private final EnumSet<OccurrenceColumn> columns;

  private final EnumSet<OccurrenceSummaryField> summaryColumn;


  /**
   * Default constructor. Creates a instance containing the default elements.
   */
  public OccurrenceTable() {
    this.columns = EnumSet.allOf(OccurrenceColumn.class);
    this.summaryColumn = EnumSet.copyOf(defaulSummaryFields);
  }


  /**
   * Creates an instance container the columns and summary fields set in the request parameter.
   */
  public OccurrenceTable(HttpServletRequest request, SearchRequest<OccurrenceSearchParameter> searchRequest) {
    this.columns = retrieveColumns(request, searchRequest);
    this.summaryColumn = retrieveSummaryFields(request, searchRequest);
  }

  /**
   * Holds the list of visible columns, the default value is OccurrenceColumn.values(). Values can be set by setting the
   * parameter 'columns'.
   */
  public EnumSet<OccurrenceColumn> getColumns() {
    return columns;
  }

  /**
   * Gets the html.table.td colspan value for the summary column.
   */
  public int getSummaryColspan() {
    // +1 because summary column is always shown
    return columns.size() + 1;
  }

  /**
   * Summary column contains basic occurrence information, its default values are OCCURRENCE_KEY, CATALOGUE_NUMBER,
   * SCIENTIFIC_NAME, INSTITUTION.
   */
  public EnumSet<OccurrenceSummaryField> getSummaryColumn() {
    return summaryColumn;
  }


  /**
   * Checks if the column parameter exists in the list of columns.
   */
  public boolean hasColumn(OccurrenceColumn column) {
    return columns.contains(column);
  }

  /**
   * Checks if the column name parameter exists in the list of columns.
   */
  public boolean hasColumn(String column) {
    return columns.contains(OccurrenceColumn.valueOf(column));
  }

  /**
   * Checks if the field parameter exists in the list of summary fields.
   */
  public boolean hasSummaryField(OccurrenceSummaryField field) {
    return summaryColumn.contains(field);
  }


  /**
   * Checks if the column name parameter exists in the list of summary fields.
   */
  public boolean hasSummaryField(String column) {
    return summaryColumn.contains(OccurrenceSummaryField.valueOf(column));
  }

  private boolean isParameterPresent(SearchRequest<OccurrenceSearchParameter> request,
    OccurrenceSearchParameter... parameters) {
    for (OccurrenceSearchParameter parameter : parameters) {
      if (request.getParameters().containsKey(parameter)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Retrieve the columns from the request parameter.
   * The default fields are returned if no value is gotten from the request.
   */
  private EnumSet<OccurrenceColumn> retrieveColumns(HttpServletRequest request,
    SearchRequest<OccurrenceSearchParameter> searchRequest) {
    EnumSet<OccurrenceColumn> requestCols = retrieveEnumParams(request, OccurrenceColumn.class, COLUMNS_PARAM);
    if (requestCols.isEmpty()) {
      requestCols = EnumSet.allOf(OccurrenceColumn.class);
    }
    if (isParameterPresent(searchRequest, OCC_LOCATION_PARAMS)) {
      requestCols.add(OccurrenceColumn.LOCATION);
    }
    if (isParameterPresent(searchRequest, OccurrenceSearchParameter.BASIS_OF_RECORD)) {
      requestCols.add(OccurrenceColumn.BASIS_OF_RECORD);
    }
    if (isParameterPresent(searchRequest, OCC_DATE_PARAMS)) {
      requestCols.add(OccurrenceColumn.DATE);
    }
    return requestCols;
  }


  /**
   * Retrieve an EnumSet containing a list of Enum literals if type T that can be obtained from the request parameter
   * paramName.
   */
  private <T extends Enum<T>> EnumSet<T> retrieveEnumParams(HttpServletRequest request, Class<T> enumClass,
    String paramName) {
    EnumSet<T> allCols = EnumSet.noneOf(enumClass);
    final String[] values = request.getParameterValues(paramName);
    if (values != null) {
      for (String paramValue : values) {
        for (String value : paramValue.split(",")) {
          Optional<T> optValue = Enums.getIfPresent(enumClass, value);
          if (optValue.isPresent()) {
            allCols.add(optValue.get());
          }
        }
      }
    }
    return allCols;
  }


  /**
   * Retrieve the summary fields from the request.
   * The default fields are returned if no value is gotten from the request.
   */
  private EnumSet<OccurrenceSummaryField> retrieveSummaryFields(HttpServletRequest request,
    SearchRequest<OccurrenceSearchParameter> searchRequest) {
    EnumSet<OccurrenceSummaryField> fields =
      retrieveEnumParams(request, OccurrenceSummaryField.class, SUMMARY_FIELDS_PARAM);
    if (fields.isEmpty()) {
      fields.addAll(defaulSummaryFields);
    }
    if (isParameterPresent(searchRequest, OccurrenceSearchParameter.CATALOG_NUMBER)) {
      fields.add(OccurrenceSummaryField.CATALOG_NUMBER);
    }
    if (isParameterPresent(searchRequest, OccurrenceSearchParameter.COLLECTION_CODE)) {
      fields.add(OccurrenceSummaryField.COLLECTION_CODE);
    }
    if (isParameterPresent(searchRequest, OccurrenceSearchParameter.COLLECTOR_NAME)) {
      fields.add(OccurrenceSummaryField.COLLECTOR_NAME);
    }
    if (isParameterPresent(searchRequest, OccurrenceSearchParameter.INSTITUTION_CODE)) {
      fields.add(OccurrenceSummaryField.INSTITUTION);
    }
    if (isParameterPresent(searchRequest, OccurrenceSearchParameter.TAXON_KEY)) {
      fields.add(OccurrenceSummaryField.SCIENTIFIC_NAME);
    }
    if (isParameterPresent(searchRequest, OccurrenceSearchParameter.MODIFIED)) {
      fields.add(OccurrenceSummaryField.MODIFIED);
    }
    return fields;
  }
}
