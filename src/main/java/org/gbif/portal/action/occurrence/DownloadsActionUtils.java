package org.gbif.portal.action.occurrence;

import org.gbif.api.model.occurrence.Download;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.service.checklistbank.NameUsageService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.util.occurrence.HumanFilterBuilder;
import org.gbif.portal.action.BaseAction;

import java.util.EnumSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.ResourceBundle;

import com.google.common.base.Enums;
import com.google.common.base.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Common utility functions for download actions.
 */
public class DownloadsActionUtils {

  public static final String DOWNLOAD_EXIST_ERR_KEY = "download.doesnt.exist";
  public static final String DOWNLOAD_NULL_ERR_KEY = "download.key.null";
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

  public static boolean isDownloadRunning(String strStatus) {
    Optional<Download.Status> optStatus = Enums.getIfPresent(Download.Status.class, strStatus);
    return optStatus.isPresent() && RUNNING_STATUSES.contains(optStatus.get());
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

  /**
   * Log and error and set an error to the field jobId.
   */
  public static void setDownloadError(BaseAction action, String messageKey, String downloadKey) {
    String errorText = action.getText(messageKey, new String[] {downloadKey});
    LOG.error(errorText);
    action.addFieldError(DOWNLOAD_KEY_PARAM, errorText);
  }
}
