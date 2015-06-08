package org.gbif.portal.action.occurrence;

import org.gbif.api.model.occurrence.DownloadFormat;
import org.gbif.api.model.occurrence.DownloadRequest;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.service.occurrence.DownloadRequestService;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.action.occurrence.util.PredicateFactory;
import org.gbif.ws.response.GbifResponseStatus;

import java.util.Set;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Response;

import com.google.common.base.Splitter;
import com.google.common.base.Throwables;
import com.google.common.collect.Sets;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Executes a download request.
 * This action has to be executed using a POST method, and error is thrown in any other case.
 */
public class DownloadRequestAction extends BaseAction {

  private static final long serialVersionUID = 3653614424275432914L;
  private static final Logger LOG = LoggerFactory.getLogger(DownloadRequestAction.class);
  private static final Splitter EMAIL_SPLITTER = Splitter.on(',').trimResults().omitEmptyStrings();
  private static final  String FORBIDDEN_DOWNLOAD = "forbidden";
  private final PredicateFactory predicateFactory = new PredicateFactory();

  @Inject
  private DownloadRequestService downloadRequestService;

  private String key;
  // optional additional email notifications
  private Set<String> emails = Sets.newHashSet();

  private DownloadFormat format;

  @Override
  public String execute() {
    @SuppressWarnings("unchecked")
    Predicate p = predicateFactory.build(getServletRequest().getParameterMap());
    LOG.info("Predicate build for passing to download [{}]", p);
    emails.add(getCurrentUser().getEmail());
    DownloadRequest download =
      new DownloadRequest(p, getCurrentUser().getUserName(), emails, true, format);
    LOG.debug("Creating download with DownloadRequest [{}] from service [{}]", download, downloadRequestService);
    try {
      key = downloadRequestService.create(download);
      LOG.debug("Got key [{}] for new download", key);
      return SUCCESS;
    } catch(WebApplicationException ex) {
      if(GbifResponseStatus.ENHANCE_YOUR_CALM.getStatus() == ex.getResponse().getStatus()){
        return FORBIDDEN_DOWNLOAD;
      }
      throw Throwables.propagate(ex);
    }
  }


  /**
   * Download notification addresses.
   */
  public Set<String> getEmails() {
    return emails;
  }

  /**
   * Download key.
   */
  public String getKey() {
    return key;
  }

  /**
   * Sets the email field, the parameter is split by ';'.
   */
  public void setEmails(String emails) {
    this.emails = Sets.newHashSet(EMAIL_SPLITTER.split(emails));
  }

  /**
   * Download requested format.
   */
  public String getFormat() {
    return format.name();
  }

  /**
   * Sets the download requested format.
   */
  public void setFormat(String format) {
    this.format = DownloadFormat.valueOf(format);
  }

}
