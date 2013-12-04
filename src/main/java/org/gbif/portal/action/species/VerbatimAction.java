package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.VerbatimNameUsage;
import org.gbif.portal.exception.NotFoundException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class VerbatimAction extends UsageBaseAction {
  private static final Logger LOG = LoggerFactory.getLogger(VerbatimAction.class);

  private VerbatimNameUsage verbatim;

  @Override
  public String execute() {

    loadUsage();

    verbatim = usageService.getVerbatim(id);
    if (verbatim == null) {
      throw new NotFoundException("No verbatim usage found with id " + id);
    }

    return SUCCESS;
  }

  public VerbatimNameUsage getVerbatim() {
    return verbatim;
  }
}
