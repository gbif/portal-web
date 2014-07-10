package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.NameUsageExtension;
import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.service.checklistbank.NameUsageExtensionService;

public class SeeMoreAction<T extends NameUsageExtension> extends UsageBaseAction {

  private PagingResponse<T> page;
  private long offset = 0;
  private final NameUsageExtensionService<T> service;

  public SeeMoreAction(NameUsageExtensionService<T> service) {
    this.service = service;
  }

  @Override
  public String execute() {
    loadUsage();

    PagingRequest p = new PagingRequest(offset, 25);
    page = service.listByUsage(id, p);

    return SUCCESS;
  }

  public void setOffset(long offset) {
    if (offset >= 0) {
      this.offset = offset;
    }
  }

  public PagingResponse<T> getPage() {
    return page;
  }
}
