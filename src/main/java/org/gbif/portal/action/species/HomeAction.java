package org.gbif.portal.action.species;

import org.gbif.api.model.Constants;
import org.gbif.api.model.checklistbank.DatasetMetrics;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.vocabulary.Extension;
import org.gbif.api.vocabulary.Rank;
import org.gbif.portal.action.BaseAction;

import java.util.UUID;

import com.google.inject.Inject;

import static org.gbif.api.model.Constants.NUB_DATASET_KEY;

@SuppressWarnings("serial")
public class HomeAction extends BaseAction {

  public static final UUID COL_KEY = UUID.fromString("7ddf754f-d193-4cc9-b351-99906754a03b");


  @Inject
  private DatasetMetricsService metricsService;

  private DatasetMetrics colMetrics;
  private DatasetMetrics nubMetrics;

  @Override
  public String execute() {
    nubMetrics = metricsService.get(Constants.NUB_DATASET_KEY);
    colMetrics = metricsService.get(COL_KEY);
    // make sure we have at least an empty one
    // this should hardly ever happen, but maybe we just killed all metrics or just start a fresh CLB
    if (nubMetrics==null) {
      nubMetrics = new DatasetMetrics();
    }
    if (colMetrics==null) {
      colMetrics = new DatasetMetrics();
    }
    return SUCCESS;
  }

  /**
   * Exposed to allow easy access in freemarker.
   */
  public UUID getNubDatasetKey() {
    return NUB_DATASET_KEY;
  }

  public DatasetMetrics getNubMetrics() {
    return nubMetrics;
  }

  public int getNubCommonNames() {
    return nubMetrics.getExtensionRecordCount(Extension.VERNACULAR_NAME);
  }

  public int getNubInfraSpecies() {
    return nubMetrics.getCountByRank(Rank.INFRASPECIFIC_NAME);
  }

  public int getNubLanguages() {
    return nubMetrics.getCountNamesByLanguage().size();
  }

  public int getNubSpecies() {
    return nubMetrics.getCountByRank(Rank.SPECIES);
  }

  public int getColSpecies() {
    return colMetrics.getCountByRank(Rank.SPECIES);
  }

  public DatasetMetrics getColMetrics() {
    return colMetrics;
  }

  public static UUID getColKey() {
    return COL_KEY;
  }

}
