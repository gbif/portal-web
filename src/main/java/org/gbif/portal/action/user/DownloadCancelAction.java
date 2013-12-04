/*
 * Copyright 2011 Global Biodiversity Information Facility (GBIF) Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and limitations under the
 * License.
 */
package org.gbif.portal.action.user;

import org.gbif.api.model.occurrence.Download;
import org.gbif.api.service.occurrence.DownloadRequestService;
import org.gbif.api.service.registry.OccurrenceDownloadService;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.action.occurrence.DownloadsActionUtils;

import com.google.common.base.Strings;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Manages user downloads. Default action lists a page of downloads,
 * the cancel method can be used to cancel a single download and then return the list again.
 */
public class DownloadCancelAction extends BaseAction {

  private static final long serialVersionUID = -8026802291497869845L;

  private static final Logger LOG = LoggerFactory.getLogger(DownloadCancelAction.class);

  private String key;

  @Inject
  private DownloadRequestService downloadRequestService;

  @Inject
  private OccurrenceDownloadService occurrenceDownloadService;

  @Override
  public String execute() {
    if (!Strings.isNullOrEmpty(key)) {
      LOG.info("Cancel request for download {}", key);
      Download download = occurrenceDownloadService.get(key);
      if (download != null && download.getRequest().getCreator().equals(getCurrentUser().getUserName())
        && DownloadsActionUtils.RUNNING_STATUSES.contains(download.getStatus())) {
        downloadRequestService.cancel(key);
      }
    }
    // to be used via POST/REDIRECT/GET
    return SUCCESS;
  }

  public void setKey(String key) {
    this.key = key;
  }

}
