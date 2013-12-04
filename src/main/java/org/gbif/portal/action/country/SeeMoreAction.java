package org.gbif.portal.action.country;

import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.occurrence.OccurrenceCountryIndexService;
import org.gbif.api.service.occurrence.OccurrenceDatasetIndexService;
import org.gbif.api.service.registry.DatasetSearchService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.NodeService;
import org.gbif.api.service.registry.OrganizationService;

import com.google.inject.Inject;

public class SeeMoreAction extends CountryBaseAction {

  private boolean about = false;

  @Inject
  public SeeMoreAction(NodeService nodeService, CubeService cubeService,
    OccurrenceDatasetIndexService datasetIndexService, OccurrenceCountryIndexService countryIndexService,
    DatasetService datasetService, DatasetSearchService datasetSearchService,
    DatasetMetricsService datasetMetricsService, OrganizationService organizationService) {
    super(nodeService, cubeService, datasetIndexService, countryIndexService, datasetService, datasetSearchService,
      datasetMetricsService, organizationService);
  }

  public String countriesAbout() throws Exception {
    about = true;
    return countriesPublished();
  }

  public String countriesPublished() throws Exception {
    super.execute();

    loadCountryPage(about, 25);

    return SUCCESS;
  }

  public String datasets() throws Exception {
    super.execute();

    loadAboutDatasetsPage(25);

    return SUCCESS;
  }

  public boolean isAbout() {
    return about;
  }

  @Override
  public String publishers() throws Exception {
    super.execute();

    loadPublishers(25);

    return SUCCESS;
  }
}
