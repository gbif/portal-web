package org.gbif.portal.action.occurrence;

import org.gbif.api.model.occurrence.Download;
import org.gbif.api.service.registry.OccurrenceDownloadService;
import org.gbif.portal.action.BaseAction;
import org.gbif.utils.file.FileUtils;

import java.util.Set;

import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.gbif.portal.action.occurrence.DownloadsActionUtils.DOWNLOAD_EXIST_ERR_KEY;
import static org.gbif.portal.action.occurrence.DownloadsActionUtils.DOWNLOAD_NULL_ERR_KEY;

public class DownloadResultAction extends BaseAction {

  private static final long serialVersionUID = -976893753100950798L;
  private static final String TITLE_READY_KEY = "download.title.ready";
  private static final String TITLE_STARTED_KEY = "download.title.started";
  private static final String TITLE_ERROR_KEY = "download.title.error";
  private static final String DOWNLOAD_KEY_PARAM = "key";
  private static final Logger LOG = LoggerFactory.getLogger(DownloadResultAction.class);


  @Inject
  private OccurrenceDownloadService downloadService;

  private String key;

  private Download download;


  @Override
  public String execute() {
    if (key != null) {
      download = downloadService.get(key);
      if (download == null || !download.getRequest().getCreator().equals(getCurrentUser().getUserName())) {
        logAndSetError(DOWNLOAD_EXIST_ERR_KEY);
      } else {
        key = download.getKey();
      }
    } else {
      logAndSetError(DOWNLOAD_NULL_ERR_KEY);
    }
    return SUCCESS;
  }

  /**
   * Download object. Null if the jobId is not a valid download.key.
   */
  public Download getDownload() {
    return download;
  }

  /**
   * Notification addresses of the download requested.
   */
  public Set<String> getEmails() {
    return download.getRequest().getNotificationAddresses();
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

  public String getPageTitle() {
    if (hasFieldErrors()) {
      return getText(TITLE_ERROR_KEY);
    } else if (download != null && download.isAvailable()) {
      return getText(TITLE_READY_KEY);
    }
    return getText(TITLE_STARTED_KEY);
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

  /**
   * Log and error and set an error to the field jobId.
   */
  private void logAndSetError(String messageKey) {
    String errorText = getText(messageKey, new String[] {key});
    LOG.error(errorText);
    addFieldError(DOWNLOAD_KEY_PARAM, errorText);
  }
}
