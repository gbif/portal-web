package org.gbif.portal.action.dataset;

import org.gbif.api.model.Constants;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.vocabulary.DatasetType;
import org.gbif.portal.action.species.HomeAction;
import org.gbif.portal.exception.NotFoundException;

import java.util.UUID;

import com.google.inject.Inject;

/**
 * Extends the details action to return a different result name based on the dataset type, so we can use
 * different freemarker templates for them as they are very different.
 * For external datasets the page is not found.
 */
public class StatsAction extends DetailAction {

  private static final String OCCURRENCE_RESULT = "occurrence";
  private static final String CHECKLIST_RESULT = "checklist";

  @Inject
  public StatsAction(DatasetService datasetService, CubeService cubeService,
    DatasetMetricsService datasetMetricsService, OrganizationService organizationService) {
    super(datasetService, cubeService, datasetMetricsService, organizationService);
  }

  @Override
  public String execute() {
    super.execute();

    if (DatasetType.OCCURRENCE == member.getType()) {
      return OCCURRENCE_RESULT;
    } else if (DatasetType.CHECKLIST == member.getType()) {
      return CHECKLIST_RESULT;
    } else {
      throw new NotFoundException("External datasets don't have a stats page");
    }
  }

  public UUID getColKey() {
    return HomeAction.COL_KEY;
  }

  public UUID getNubKey() {
    return Constants.NUB_DATASET_KEY;
  }
}
