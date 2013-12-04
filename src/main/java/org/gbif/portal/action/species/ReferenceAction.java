package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.Reference;
import org.gbif.api.service.checklistbank.ReferenceService;

import com.google.inject.Inject;

public class ReferenceAction extends SeeMoreAction<Reference> {

  @Inject
  public ReferenceAction(ReferenceService service) {
    super(service);
  }
}
