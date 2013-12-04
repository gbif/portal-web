package org.gbif.portal.action.dataset;

import org.gbif.api.model.common.search.SearchResponse;
import org.gbif.api.model.registry.search.DatasetSearchParameter;
import org.gbif.api.model.registry.search.DatasetSearchRequest;
import org.gbif.api.model.registry.search.DatasetSearchResult;
import org.gbif.api.service.registry.DatasetSearchService;
import org.gbif.api.vocabulary.DatasetType;
import org.gbif.portal.action.BaseAction;

import com.google.inject.Inject;
import com.google.inject.Singleton;

/**
 * The home action uses the dataset search index to produce basic metrics.
 */
@Singleton
public class HomeAction extends BaseAction {

  private static final long serialVersionUID = 3791960822111920288L;

  private long numOccurrenceDatasets;
  private long numChecklistDatasets;
  private long numMetadataDatasets;
  private long numDatasets;

  private final DatasetSearchService service;

  @Inject
  public HomeAction(DatasetSearchService service) {
    this.service = service;
  }

  @Override
  public String execute() {
    numOccurrenceDatasets = count(DatasetType.OCCURRENCE);
    numChecklistDatasets = count(DatasetType.CHECKLIST);
    numMetadataDatasets = count(DatasetType.METADATA);
    numDatasets = numOccurrenceDatasets + numChecklistDatasets + numMetadataDatasets;
    return SUCCESS;
  }

  public long getNumChecklistDatasets() {
    return numChecklistDatasets;
  }

  public long getNumDatasets() {
    return numDatasets;
  }

  public long getNumMetadataDatasets() {
    return numMetadataDatasets;
  }

  public long getNumOccurrenceDatasets() {
    return numOccurrenceDatasets;
  }

  /**
   * Uses the {@link DatasetSearchService} to find the count of records.
   * 
   * @param type To count
   * @return The count, or 0 should the service be unresponsive
   */
  private long count(DatasetType type) {
    DatasetSearchRequest dsr = new DatasetSearchRequest();
    dsr.setLimit(0); // we don't need any
    dsr.addParameter(DatasetSearchParameter.TYPE, type);
    SearchResponse<DatasetSearchResult, DatasetSearchParameter> response = service.search(dsr);
    return (response == null || response.getCount() == null) ? 0 : response.getCount(); // NPE safe
  }
}
