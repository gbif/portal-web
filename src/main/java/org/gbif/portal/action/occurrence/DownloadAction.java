package org.gbif.portal.action.occurrence;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.occurrence.Download;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.model.registry.DatasetOccurrenceDownloadUsage;
import org.gbif.api.service.checklistbank.NameUsageService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.OccurrenceDownloadService;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.action.occurrence.util.DownloadsActionUtils;
import org.gbif.portal.exception.NotFoundException;
import org.gbif.utils.file.FileUtils;

import java.util.LinkedList;
import java.util.Map;

import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DownloadAction extends BaseAction {

  private static final long serialVersionUID = -976893753100950798L;
  private static final Logger LOG = LoggerFactory.getLogger(DownloadAction.class);
  private static final int DEFAULT_LIMIT = 25;

  private final OccurrenceDownloadService downloadService;
  private final NameUsageService nameUsageService;
  private final DatasetService datasetService;
  private final PagingRequest request = new PagingRequest(0, DEFAULT_LIMIT);

  private String key;
  private Download download;
  private PagingResponse<DatasetOccurrenceDownloadUsage> datasetUsages;

  @Inject
  public DownloadAction(OccurrenceDownloadService downloadService, NameUsageService nameUsageService,
    DatasetService datasetService){
    this.downloadService = downloadService;
    this.nameUsageService = nameUsageService;
    this.datasetService = datasetService;
  }
  @Override
  public String execute() {
    download = downloadService.get(key);
    if (download == null) {
      throw new NotFoundException("No download found with key " + key);
    }
    LOG.debug("Fetching used datasets for download [{}]", download);
    datasetUsages = downloadService.listDatasetUsages(key, request);
    return SUCCESS;
  }

  /**
   * Download object. Null if the jobId is not a valid download.key.
   */
  public Download getDownload() {
    return download;
  }

  public String getHumanRedeableBytesSize(long bytes) {
    return FileUtils.humanReadableByteCount(bytes, true);
  }

  /**
   * Download key.
   */
  public String getKey() {
    return key;
  }

  public boolean isRunning() {
    return DownloadsActionUtils.isRunning(download);
  }

  public boolean dwcaExists() {
    return DownloadsActionUtils.dwcaExists(download);
  }

  public void setKey(String key) {
    this.key = key;
  }

  public void setOffset(long offset) {
    request.setOffset(offset);
  }

  public PagingResponse<DatasetOccurrenceDownloadUsage> getPage() {
    return datasetUsages;
  }

  // needed by freemarker filter macro
  public String getQueryParams(Predicate p) {
    return DownloadsActionUtils.getQueryParams(p);
  }

  // needed by freemarker filter macro
  public Map<OccurrenceSearchParameter, LinkedList<String>> getHumanFilter(Predicate p) {
    return DownloadsActionUtils.getHumanFilter(p,datasetService,nameUsageService,getTexts());
  }
}
