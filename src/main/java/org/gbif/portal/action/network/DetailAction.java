package org.gbif.portal.action.network;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.model.registry.Network;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.NetworkService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.portal.action.member.MemberBaseAction;
import org.gbif.portal.action.member.MemberType;

import com.google.inject.Inject;

public class DetailAction extends MemberBaseAction<Network> {

  private final NetworkService networkService;
  private PagingResponse<Dataset> page;
  private long offset = 0;

  @Inject
  public DetailAction(NetworkService networkService, OrganizationService organizationService, CubeService cubeService,
    DatasetMetricsService datasetMetricsService) {
    super(MemberType.NETWORK, networkService, cubeService, datasetMetricsService, organizationService);
    this.networkService = networkService;
  }

  @Override
  public String execute() throws Exception {
    super.execute();

    // load first 10 datasets
    page = networkService.listConstituents(id, new PagingRequest(0, 10));
    super.loadCountWrappedDatasets(page);

    return SUCCESS;
  }

  public String datasets() throws Exception {
    super.execute();
    page = networkService.listConstituents(id, new PagingRequest(offset, 25));
    return SUCCESS;
  }

  public PagingResponse<Dataset> getPage() {
    return page;
  }

  public void setOffset(long offset) {
    if (offset >= 0) {
      this.offset = offset;
    }
  }
}
