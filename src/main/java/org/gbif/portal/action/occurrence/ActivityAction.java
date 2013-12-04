package org.gbif.portal.action.occurrence;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ActivityAction extends OccurrenceBaseAction {

  private static final Logger LOG = LoggerFactory.getLogger(ActivityAction.class);

  @Override
  public String execute() {
    loadDetail();
    return SUCCESS;
  }

}
