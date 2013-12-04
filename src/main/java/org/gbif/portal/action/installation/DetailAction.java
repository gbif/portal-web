package org.gbif.portal.action.installation;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.model.registry.Installation;
import org.gbif.api.model.registry.Organization;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.InstallationService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.portal.action.member.MemberBaseAction;
import org.gbif.portal.action.member.MemberType;

import com.google.inject.Inject;

public class DetailAction extends MemberBaseAction<Installation> {

  private final OrganizationService organizationService;
  private final InstallationService installationService;

  private Organization organization;
  private PagingResponse<Dataset> page;
  private long offset = 0;

  @Inject
  public DetailAction(OrganizationService organizationService, InstallationService installationService,
    CubeService cubeService, DatasetMetricsService datasetMetricsService) {
    super(MemberType.INSTALLATION, installationService, cubeService, datasetMetricsService, organizationService);
    this.organizationService = organizationService;
    this.installationService = installationService;
  }

  public String datasets() throws Exception {
    super.execute();
    page = installationService.getHostedDatasets(id, new PagingRequest(offset, 25));
    return SUCCESS;
  }

  @Override
  public String execute() throws Exception {
    super.execute();
    // load hosting organization
    if (member.getOrganizationKey() != null) {
      organization = organizationService.get(member.getOrganizationKey());
    }
    // load first 10 datasets
    page = installationService.getHostedDatasets(id, new PagingRequest(0, 10));
    super.loadCountWrappedDatasets(page);

    return SUCCESS;
  }

  public Organization getOrganization() {
    return organization;
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

