package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.NameUsage;

import java.util.List;

public class CombinationsAction extends UsageBaseAction {

  private List<NameUsage> usages;

  @Override
  public String execute() {
    loadUsage();

    usages = usageService.listCombinations(id, getLocale());

    return SUCCESS;
  }

  public List<NameUsage> getUsages() {
    return usages;
  }
}
