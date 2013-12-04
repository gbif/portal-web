package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.NameUsage;

import java.util.List;

public class ClassificationAction extends UsageBaseAction {

  private List<NameUsage> parents;

  @Override
  public String execute() {
    loadUsage();

    parents = usageService.listParents(id, getLocale());
    return SUCCESS;
  }

  public List<NameUsage> getParents() {
    return parents;
  }
}
