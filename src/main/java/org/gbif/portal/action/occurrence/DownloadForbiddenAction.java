package org.gbif.portal.action.occurrence;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.occurrence.Download;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.model.registry.DatasetOccurrenceDownloadUsage;
import org.gbif.api.service.registry.OccurrenceDownloadService;
import org.gbif.occurrence.query.TitleLookup;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.action.occurrence.util.DownloadsActionUtils;
import org.gbif.portal.exception.NotFoundException;
import org.gbif.utils.file.FileUtils;

import java.util.LinkedList;
import java.util.Map;

import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DownloadForbiddenAction extends BaseAction {

  private static final Logger LOG = LoggerFactory.getLogger(DownloadForbiddenAction.class);

  private final OccurrenceDownloadService downloadService;
  private final static  PagingRequest REQUEST = new PagingRequest(0, 0);

  private PagingResponse<Download> downloads;


  @Inject
  public DownloadForbiddenAction(OccurrenceDownloadService downloadService) {
    this.downloadService = downloadService;
  }

  @Override
  public String execute() {
    downloads = downloadService.listByUser(getCurrentUser().getUserName(), REQUEST, Download.Status.EXECUTING_STATUSES);
    return SUCCESS;
  }

  public PagingResponse<Download> getDownloads() {
    return downloads;
  }

  public void setDownloads(PagingResponse<Download> downloads) {
    this.downloads = downloads;
  }
}
