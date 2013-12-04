package org.gbif.portal.action.occurrence;

import org.gbif.api.model.occurrence.Download;

import java.util.EnumSet;

import com.google.common.base.Enums;
import com.google.common.base.Optional;

/**
 * Common utility functions for download actions.
 */
public class DownloadsActionUtils {

  public static final String DOWNLOAD_EXIST_ERR_KEY = "download.doesnt.exist";
  public static final String DOWNLOAD_NULL_ERR_KEY = "download.key.null";

  public static final EnumSet<Download.Status> RUNNING_STATUSES = EnumSet.of(Download.Status.PREPARING,
    Download.Status.RUNNING, Download.Status.SUSPENDED);

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
}
