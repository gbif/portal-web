package org.gbif.portal.action.dataset;

import org.gbif.api.model.Constants;
import org.gbif.api.model.metrics.cube.OccurrenceCube;
import org.gbif.api.model.metrics.cube.ReadBuilder;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.vocabulary.BasisOfRecord;
import org.gbif.api.vocabulary.DatasetType;
import org.gbif.api.vocabulary.Kingdom;
import org.gbif.api.vocabulary.OccurrenceIssue;
import org.gbif.api.vocabulary.TypeStatus;
import org.gbif.portal.action.species.HomeAction;
import org.gbif.portal.exception.NotFoundException;

import java.util.Map;
import java.util.UUID;

import com.google.common.collect.Maps;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Extends the details action to return a different result name based on the dataset type, so we can use
 * different freemarker templates for them as they are very different.
 * For external datasets the page is not found.
 */
public class StatsAction extends DetailAction {
  private static final Logger LOG = LoggerFactory.getLogger(StatsAction.class);

  // OCCURRENCE ONLY, checklist use the DatasetMetrics class
  // breakdown by kingdom
  private Map<Kingdom, Long> countByKingdom = Maps.newHashMap();
  // breakdown by basis of record
  private Map<BasisOfRecord, Long> countByBor = Maps.newHashMap();
  // breakdown by types
  private Map<TypeStatus, Long> countByTypes = Maps.newHashMap();
  // breakdown by issues
  private Map<Enum<?>, Long> countByIssues = Maps.newHashMap();

  @Inject
  public StatsAction(DatasetService datasetService, CubeService cubeService,
    DatasetMetricsService datasetMetricsService, OrganizationService organizationService) {
    super(datasetService, cubeService, datasetMetricsService, organizationService);
  }

  @Override
  public String execute() {
    super.execute();

    if (DatasetType.OCCURRENCE == member.getType() || DatasetType.CHECKLIST == member.getType()
        || DatasetType.SAMPLING_EVENT == member.getType()) {
      populateOccMetrics();
      return SUCCESS;
    } else {
      throw new NotFoundException("External datasets don't have a stats page");
    }
  }

  private void populateOccMetrics() {
    try {
      for (Kingdom k : Kingdom.values()) {
        long cnt = occurrenceCubeService.get( readBuilder().at(OccurrenceCube.TAXON_KEY, k.nubUsageID()) );
        if (cnt > 0) {
          countByKingdom.put(k, cnt);
        }
      }
    } catch (IllegalArgumentException e) {
      LOG.error("Cant get kingdom metrics", e);
    }

    try {
      for (BasisOfRecord k : BasisOfRecord.values()) {
        long cnt = occurrenceCubeService.get( readBuilder().at(OccurrenceCube.BASIS_OF_RECORD, k) );
        if (cnt > 0) {
          countByBor.put(k, cnt);
        }
      }
    } catch (IllegalArgumentException e) {
      LOG.error("Cant get BoR metrics", e);
    }

    try {
        for (TypeStatus k : TypeStatus.values()) {
        long cnt = occurrenceCubeService.get( readBuilder().at(OccurrenceCube.TYPE_STATUS, k) );
        if (cnt > 0) {
          countByTypes.put(k, cnt);
        }
      }
    } catch (IllegalArgumentException e) {
      LOG.error("Cant get types metrics", e);
    }

    try {
      for (OccurrenceIssue k : OccurrenceIssue.values()) {
        long cnt = occurrenceCubeService.get( readBuilder().at(OccurrenceCube.ISSUE, k) );
        if (cnt > 0) {
          countByIssues.put(k, cnt);
        }
      }
    } catch (IllegalArgumentException e) {
      LOG.error("Cant get issue metrics", e);
    }
  }

  private ReadBuilder readBuilder() {
    return new ReadBuilder().at(OccurrenceCube.DATASET_KEY, id);
  }

  public UUID getColKey() {
    return HomeAction.COL_KEY;
  }

  public UUID getNubKey() {
    return Constants.NUB_DATASET_KEY;
  }

  public Map<Kingdom, Long> getCountByKingdom() {
    return countByKingdom;
  }

  public Map<BasisOfRecord, Long> getCountByBor() {
    return countByBor;
  }

  public Map<TypeStatus, Long> getCountByTypes() {
    return countByTypes;
  }

  public Map<?, Long> getCountByIssues() {
    return countByIssues;
  }
}
