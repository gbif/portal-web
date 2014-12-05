package org.gbif.portal.action.occurrence;

import org.gbif.api.model.common.paging.Pageable;
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
import org.gbif.portal.action.user.DownloadsAction;
import org.gbif.utils.file.FileUtils;

import java.util.LinkedList;
import java.util.Map;

import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.gbif.portal.action.occurrence.DownloadsActionUtils.DOWNLOAD_EXIST_ERR_KEY;

public class DownloadDetailAction extends BaseAction {

  private static final long serialVersionUID = -976893753100950798L;
  private static final Logger LOG = LoggerFactory.getLogger(DownloadDetailAction.class);
  private final PagingRequest request = new PagingRequest(0, DEFAULT_LIMIT);
  private static final int DEFAULT_LIMIT = 10;

  private final OccurrenceDownloadService downloadService;

  private final NameUsageService nameUsageService;

  private final DatasetService datasetService;

  private String key;

  private Download download;

  private PagingResponse<DatasetOccurrenceDownloadUsage> datasetUsages;

  @Inject
  public DownloadDetailAction(OccurrenceDownloadService downloadService, NameUsageService nameUsageService,  DatasetService datasetService){
    this.downloadService = downloadService;
    this.nameUsageService = nameUsageService;
    this.datasetService = datasetService;
  }
  @Override
  public String execute() {
    if (key != null) {
      download = downloadService.get(key);
      if(download != null) {
        LOG.debug("Fetching download [{}]", download);
        datasetUsages = downloadService.listDatasetUsages(key, request);
      } else {
        DownloadsActionUtils.setDownloadError(this, DOWNLOAD_EXIST_ERR_KEY, key);
      }
      return SUCCESS;
    }
    return ERROR;
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


  /**
   * Checks if the download is running.
   */
  public boolean isDownloadRunning(String strStatus) {
    return DownloadsActionUtils.isDownloadRunning(strStatus);
  }

  public void setKey(String key) {
    this.key = key;
  }

  public void setOffset(long offset) {
    request.setOffset(offset);
  }

  public boolean showDownload(){
    return !hasFieldErrors() && download != null && download.isAvailable();
  }

  public Pageable getPage() {
    return datasetUsages;
  }

  public String getQueryParams(Predicate p) {
    return DownloadsAction.getQueryParams(p);
  }

  public Map<OccurrenceSearchParameter, LinkedList<String>> getHumanFilter(Predicate p) {
    return DownloadsActionUtils.getHumanFilter(p,datasetService,nameUsageService,getTexts());
  }
}
