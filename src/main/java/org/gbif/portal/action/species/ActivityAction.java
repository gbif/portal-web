package org.gbif.portal.action.species;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ActivityAction extends UsageBaseAction {
  private static final Logger LOG = LoggerFactory.getLogger(ActivityAction.class);

  @Override
  public String execute() {
    loadUsage();

    return SUCCESS;
  }

}
