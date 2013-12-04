package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.Distribution;
import org.gbif.api.service.checklistbank.DistributionService;

import com.google.inject.Inject;

public class DistributionAction extends SeeMoreAction<Distribution> {

  @Inject
  public DistributionAction(DistributionService service) {
    super(service);
  }
}
