package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.VernacularName;
import org.gbif.api.service.checklistbank.VernacularNameService;

import com.google.inject.Inject;

public class VernacularNameAction extends SeeMoreAction<VernacularName> {

  @Inject
  public VernacularNameAction(VernacularNameService service) {
    super(service);
  }
}