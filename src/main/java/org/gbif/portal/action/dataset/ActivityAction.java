package org.gbif.portal.action.dataset;

import org.gbif.api.model.common.paging.Pageable;
import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.model.registry.DatasetOccurrenceDownloadUsage;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.DatasetOccurrenceDownloadUsageService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.occurrence.query.TitleLookup;
import org.gbif.portal.action.occurrence.util.DownloadsActionUtils;
import org.gbif.utils.file.FileUtils;

import java.util.LinkedList;
import java.util.Map;

import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Extends the details action to return a different result name based on the dataset type, so we can use
 * different freemarker templates for them as they are very different.
 * For external datasets the page is not found.
 */
public class ActivityAction extends DetailAction {

  private static Logger LOG = LoggerFactory.getLogger(ActivityAction.class);

  private final DatasetOccurrenceDownloadUsageService downloadUsageService;
  private final TitleLookup titleLookup;
  private PagingResponse<DatasetOccurrenceDownloadUsage> response;
  private final PagingRequest request;
  private static final int DEFAULT_LIMIT = 10;

  @Inject
  public ActivityAction(DatasetService datasetService, DatasetOccurrenceDownloadUsageService downloadUsageService,
    CubeService cubeService, DatasetMetricsService datasetMetricsService,
    OrganizationService organizationService, TitleLookup titleLookup) {
    super(datasetService, cubeService, datasetMetricsService, organizationService);
    this.downloadUsageService = downloadUsageService;
    this.titleLookup = titleLookup;
    request = new PagingRequest(0, DEFAULT_LIMIT);
  }

  @Override
  public String execute() {
    super.execute();
    response = downloadUsageService.listByDataset(getId(), request);
    return SUCCESS;
  }

  public Map<OccurrenceSearchParameter, LinkedList<String>> getHumanFilter(Predicate p) {
    return DownloadsActionUtils.getHumanFilter(p, titleLookup);
  }

  public String getHumanRedeableBytesSize(long bytes) {
    return FileUtils.humanReadableByteCount(bytes, true);
  }

  public Pageable getPage() {
    return response;
  }


  public String getQueryParams(Predicate p) {
    return DownloadsActionUtils.getQueryParams(p);
  }

  public String getQueryParamsWithoutDataset(Predicate p) {
    return DownloadsActionUtils.getQueryParamsWithoutDataset(p);
  }

  public void setOffset(long offset) {
    request.setOffset(offset);
  }
}
