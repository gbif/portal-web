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
import org.gbif.api.util.occurrence.HumanFilterBuilder;
import org.gbif.api.util.occurrence.QueryParameterFilterBuilder;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.action.occurrence.DownloadsActionUtils;
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

  private PagingResponse<Download> page;

  private long offset;


  @Inject
  private OccurrenceDownloadService downloadService;

  @Inject
  private NameUsageService usageService;
  @Inject
  private DatasetService datasetService;


  public static String getQueryParams(Predicate p) {
    if (p != null) {
      try {
        // not thread safe!
        QueryParameterFilterBuilder builder = new QueryParameterFilterBuilder();
        return builder.queryFilter(p);

      } catch (Exception e) {
        LOG.warn("Cannot create query parameter representation for predicate {}", p);
      }
    }
    return null;
  }

  @Override
  public String execute() throws Exception {
    // user is never null, guaranteed by the LoginInterceptor stack
    page = downloadService.listByUser(getCurrentUser().getUserName(), new PagingRequest(offset, 25));
    return SUCCESS;
  }

  // TODO: the same code is also used in ActivityAction share it showhow!!!
  public Map<OccurrenceSearchParameter, LinkedList<String>> getHumanFilter(Predicate p) {
    if (p != null) {
      try {
        // not thread safe!
        HumanFilterBuilder builder = new HumanFilterBuilder(this.getTexts(), datasetService, usageService, true);
        return builder.humanFilter(p);

      } catch (Exception e) {
        LOG.warn("Cannot create human representation for predicate {}", p);
      }
    }
    return null;
  }

  public String getHumanRedeableBytesSize(long bytes) {
    return FileUtils.humanReadableByteCount(bytes, true);
  }

  public PagingResponse<Download> getPage() {
    return page;
  }

  public boolean isDownloadRunning(String strStatus) {
    return DownloadsActionUtils.isDownloadRunning(strStatus);
  }


  public void setOffset(long offset) {
    this.offset = offset;
  }
}
