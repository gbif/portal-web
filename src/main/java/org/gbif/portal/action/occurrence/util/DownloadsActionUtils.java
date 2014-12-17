package org.gbif.portal.action.occurrence.util;

import org.gbif.api.model.occurrence.Download;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.service.checklistbank.NameUsageService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.util.occurrence.HumanFilterBuilder;
import org.gbif.api.util.occurrence.QueryParameterFilterBuilder;

import java.util.EnumSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.ResourceBundle;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Common utility functions for download actions.
 */
public class DownloadsActionUtils {

  private static final String DOWNLOAD_KEY_PARAM = "key";

  public static final EnumSet<Download.Status> RUNNING_STATUSES = EnumSet.of(Download.Status.PREPARING,
    Download.Status.RUNNING, Download.Status.SUSPENDED);

  private static final Logger LOG = LoggerFactory.getLogger(DownloadsActionUtils.class);

  /**
   * Private constructor.
   */
  private DownloadsActionUtils() {
    // Utility class must have private constructors only
  }

  public static boolean isRunning(Download download) {
    return RUNNING_STATUSES.contains(download.getStatus());
  }

  /**
   * Returns the human readable filter of an occurrence download.
   */
  public static Map<OccurrenceSearchParameter, LinkedList<String>> getHumanFilter(Predicate p, DatasetService datasetService, NameUsageService nameUsageService, ResourceBundle resourceBundle) {
    if (p != null) {
      try {
        // not thread safe!
        HumanFilterBuilder builder = new HumanFilterBuilder(resourceBundle, datasetService, nameUsageService, true);
        return builder.humanFilter(p);

      } catch (Exception e) {
        LOG.warn("Cannot create human representation for predicate {}", p);
      }
    }
    return null;
  }

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
}
