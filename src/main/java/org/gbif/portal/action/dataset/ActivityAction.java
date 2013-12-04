package org.gbif.portal.action.dataset;

import org.gbif.api.model.common.paging.Pageable;
import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.model.registry.DatasetOccurrenceDownloadUsage;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.checklistbank.NameUsageService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.DatasetOccurrenceDownloadUsageService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.util.occurrence.HumanFilterBuilder;
import org.gbif.portal.action.user.DownloadsAction;

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
  private final NameUsageService nameUsageService;
  private PagingResponse<DatasetOccurrenceDownloadUsage> response;
  private final PagingRequest request;
  private static final int DEFAULT_LIMIT = 10;

  @Inject
  public ActivityAction(DatasetService datasetService, DatasetOccurrenceDownloadUsageService downloadUsageService,
    NameUsageService nameUsageService, CubeService cubeService, DatasetMetricsService datasetMetricsService,
    OrganizationService organizationService) {
    super(datasetService, cubeService, datasetMetricsService, organizationService);
    this.downloadUsageService = downloadUsageService;
    this.nameUsageService = nameUsageService;
    request = new PagingRequest(0, DEFAULT_LIMIT);
  }

  @Override
  public String execute() {
    super.execute();
    response = downloadUsageService.listByDataset(getId(), request);
    return SUCCESS;
  }

  // TODO: the same code is also used in DownloadsAction share it showhow!!!
  public Map<OccurrenceSearchParameter, LinkedList<String>> getHumanFilter(Predicate p) {
    if (p != null) {
      try {
        // not thread safe!
        HumanFilterBuilder builder = new HumanFilterBuilder(this.getTexts(), datasetService, nameUsageService, true);
        return builder.humanFilter(p);

      } catch (Exception e) {
        LOG.warn("Cannot create human representation for predicate {}", p);
      }
    }
    return null;
  }

  public Pageable getPage() {
    return response;
  }


  public String getQueryParams(Predicate p) {
    return DownloadsAction.getQueryParams(p);
  }

  public void setOffset(long offset) {
    request.setOffset(offset);
  }
}
