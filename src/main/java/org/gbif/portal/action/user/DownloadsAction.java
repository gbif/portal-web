/*
 * Copyright 2011 Global Biodiversity Information Facility (GBIF) Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and limitations under the
 * License.
 */
package org.gbif.portal.action.user;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.occurrence.Download;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.service.checklistbank.NameUsageService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.OccurrenceDownloadService;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.action.occurrence.util.DownloadsActionUtils;
import org.gbif.utils.file.FileUtils;

import java.util.LinkedList;
import java.util.Map;

import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Manages user downloads. Default action lists a page of downloads,
 * the cancel method can be used to cancel a single download and then return the list again.
 */
public class DownloadsAction extends BaseAction {

  private static final long serialVersionUID = 5431100837057685230L;

  private static Logger LOG = LoggerFactory.getLogger(DownloadsAction.class);

  @Inject
  private OccurrenceDownloadService downloadService;
  @Inject
  private NameUsageService usageService;
  @Inject
  private DatasetService datasetService;

  private PagingResponse<Download> page;
  private long offset;

  @Override
  public String execute() throws Exception {
    // user is never null, guaranteed by the LoginInterceptor stack
    page = downloadService.listByUser(getCurrentUser().getUserName(), new PagingRequest(offset, 25));
    return SUCCESS;
  }

  public Map<OccurrenceSearchParameter, LinkedList<String>> getHumanFilter(Predicate p) {
    return DownloadsActionUtils.getHumanFilter(p,datasetService,usageService,getTexts());
  }

  // used by the freemarker macro to render human readable file sizes
  public String getHumanRedeableBytesSize(long bytes) {
    return FileUtils.humanReadableByteCount(bytes, true);
  }

  // needed by freemarker filter macro
  public String getQueryParams(Predicate p) {
    return DownloadsActionUtils.getQueryParams(p);
  }

  public PagingResponse<Download> getPage() {
    return page;
  }

  public boolean isRunning(Download download) {
    return DownloadsActionUtils.isRunning(download);
  }

  public void setOffset(long offset) {
    this.offset = offset;
  }
}
