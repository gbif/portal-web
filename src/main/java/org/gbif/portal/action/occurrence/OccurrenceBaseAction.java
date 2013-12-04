package org.gbif.portal.action.occurrence;

import org.gbif.api.model.checklistbank.DatasetMetrics;
import org.gbif.api.model.checklistbank.NameUsage;
import org.gbif.api.model.occurrence.Occurrence;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.service.checklistbank.NameUsageService;
import org.gbif.api.service.occurrence.OccurrenceService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.exception.NotFoundException;
import org.gbif.portal.exception.ReferentialIntegrityException;

import com.google.common.base.Strings;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OccurrenceBaseAction extends BaseAction {

  private static final Logger LOG = LoggerFactory.getLogger(OccurrenceBaseAction.class);

  @Inject
  protected OccurrenceService occurrenceService;
  @Inject
  protected DatasetService datasetService;
  @Inject
  protected NameUsageService usageService;

  protected Integer id;
  protected Occurrence occ;
  protected NameUsage nub;
  protected Dataset dataset;
  protected DatasetMetrics metrics;
  protected String partialGatheringDate;

  public Dataset getDataset() {
    return dataset;
  }

  public Integer getId() {
    return id;
  }

  public DatasetMetrics getMetrics() {
    return metrics;
  }

  public NameUsage getNub() {
    return nub;
  }

  public Occurrence getOcc() {
    return occ;
  }

  /**
   * The partial gathering date, constructed from individual occurrence day, month, year.
   * 
   * @return partial gathering date
   */
  public String getPartialGatheringDate() {
    return partialGatheringDate;
  }

  public void setId(Integer id) {
    this.id = id;
  }

  /**
   * From partial gathering date's year, month, day parts construct string in following format: Oct 7, 2006.
   * Basically, only valid integers gets persisted to the index, and any invalid data will be flagged/logged.
   * This method must ensure the values gets displayed exactly as they are persisted so that if there are errors
   * they can be detected via the occurrence page also.
   * 
   * @return date string
   */
  protected String constructPartialGatheringDate(Integer year, Integer month, Integer day) {
    StringBuffer st = new StringBuffer();

    // start by adding month
    String monthString = null;
    if (month != null && month > 0) {

      switch (month) {
        case 1:
          monthString = "Jan";
          break;
        case 2:
          monthString = "Feb";
          break;
        case 3:
          monthString = "Mar";
          break;
        case 4:
          monthString = "Apr";
          break;
        case 5:
          monthString = "May";
          break;
        case 6:
          monthString = "Jun";
          break;
        case 7:
          monthString = "Jul";
          break;
        case 8:
          monthString = "Aug";
          break;
        case 9:
          monthString = "Sep";
          break;
        case 10:
          monthString = "Oct";
          break;
        case 11:
          monthString = "Nov";
          break;
        case 12:
          monthString = "Dec";
          break;
      }
      st.append(monthString);

      // add day to month separated by single whitespace, provided month has been added
      if (day != null && day > 0) {
        st.append(" ");
        st.append(String.valueOf(day));
      }
    }

    // add year
    if (year != null && year > 0) {
      // before adding year, write comma (",") if at least month has been appended to string date
      if (!Strings.isNullOrEmpty(st.toString())) {
        st.append(", ");
      }
      // now add year
      st.append(String.valueOf(year));
    }

    return st.toString();
  }

  protected void loadDetail() {
    if (id == null) {
      throw new NotFoundException("No occurrence id given");
    }
    occ = occurrenceService.get(id);
    if (occ == null) {
      throw new NotFoundException("No occurrence found with id " + id);
    }
    // load dataset
    dataset = datasetService.get(occ.getDatasetKey());
    if (dataset == null) {
      throw new ReferentialIntegrityException(Occurrence.class, id, "Missing dataset " + occ.getDatasetKey());
    }
    // load name usage nub object
    if (occ.getNubKey() != null) {
      nub = usageService.get(occ.getNubKey(), getLocale());
      if (nub == null) {
        throw new ReferentialIntegrityException(Occurrence.class, id, "Missing nub usage " + occ.getNubKey());
      }
    }
    // TODO: load metrics for occurrence once implemented
    metrics = null;
    // construct partial gathering date if occurrenceDate was empty and there is at least a year or month
    if (occ.getOccurrenceDate() == null && (occ.getOccurrenceYear() != null || occ.getOccurrenceMonth() != null)) {
      partialGatheringDate =
        constructPartialGatheringDate(occ.getOccurrenceYear(), occ.getOccurrenceMonth(), occ.getOccurrenceDay());
    }
  }
}
