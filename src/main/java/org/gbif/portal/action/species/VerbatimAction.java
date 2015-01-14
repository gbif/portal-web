package org.gbif.portal.action.species;

import org.gbif.api.model.Constants;
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
      if (Constants.NUB_DATASET_KEY.equals(usage.getDatasetKey())) {
        throw new NotFoundException("GBIF backbone taxa do not have a verbatim version");
      }
    }
    return SUCCESS;
  }

  public VerbatimNameUsage getVerbatim() {
    return verbatim;
  }
}
