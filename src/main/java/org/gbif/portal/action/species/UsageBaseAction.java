package org.gbif.portal.action.species;

import org.gbif.api.exception.ServiceUnavailableException;
import org.gbif.api.model.checklistbank.DatasetMetrics;
import org.gbif.api.model.checklistbank.NameUsage;
import org.gbif.api.model.checklistbank.NameUsageContainer;
import org.gbif.api.model.checklistbank.NameUsageMetrics;
import org.gbif.api.model.metrics.cube.OccurrenceCube;
import org.gbif.api.model.metrics.cube.ReadBuilder;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.model.registry.Organization;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.checklistbank.NameUsageService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.exception.NotFoundException;
import org.gbif.portal.exception.ReferentialIntegrityException;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.google.common.collect.Maps;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UsageBaseAction extends BaseAction {

  protected final Logger LOG = LoggerFactory.getLogger(getClass());

  @Inject
  protected NameUsageService usageService;
  @Inject
  protected DatasetService datasetService;
  @Inject
  protected DatasetMetricsService metricsService;
  @Inject
  protected CubeService occurrenceCubeService;
  @Inject
  protected OrganizationService organizationService;

  protected Integer id;
  protected NameUsageContainer usage;
  private NameUsageMetrics usageMetrics;
  protected Dataset dataset;
  private Dataset constituent;
  private Organization publisher;
  protected DatasetMetrics metrics;
  private long numOccurrences;
  private long numGeoreferencedOccurrences;
  protected Map<UUID, Dataset> datasets = Maps.newHashMap();

  /**
   * @param maxSize
   * @param <T>
   * @return list of a size not larger then maxSize
   */
  protected static <T> List<T> sublist(List<T> list, int maxSize) {
    return sublist(list, 0, maxSize);
  }

  /**
   * @param maxSize
   * @param <T>
   * @return list of a size not larger then maxSize
   */
  protected static <T> List<T> sublist(List<T> list, int start, int maxSize) {
    if (list.size() <= maxSize) {
      if (start == 0) {
        return list;
      }
      return list.subList(start, list.size());
    }
    return list.subList(start, maxSize);
  }

  public String getChecklistName(UUID key) {
    if (key != null && datasets.containsKey(key)) {
      return datasets.get(key).getTitle();
    }
    return "";
  }

  public Dataset getDataset() {
    return dataset;
  }

  public Map<UUID, Dataset> getDatasets() {
    return datasets;
  }

  public Integer getId() {
    return id;
  }

  public DatasetMetrics getMetrics() {
    return metrics;
  }

  public long getNumGeoreferencedOccurrences() {
    return numGeoreferencedOccurrences;
  }

  public long getNumOccurrences() {
    return numOccurrences;
  }

  public NameUsageContainer getUsage() {
    return usage;
  }

  public NameUsageMetrics getUsageMetrics() {
    return usageMetrics;
  }

  public boolean isNub() {
    return usage.isNub();
  }

  /**
   * Loads a name usage and its checklist by the id parameter.
   * 
   * @throws NotFoundException if no usage for the given id can be found
   */
  public void loadUsage() {
    if (id == null) {
      throw new NotFoundException("No checklist usage id given");
    }
    NameUsage u = usageService.get(id, getLocale());
    if (u == null) {
      throw new NotFoundException("No usage found with id " + id);
    }
    usage = new NameUsageContainer(u);
    usageMetrics = usageService.getMetrics(id);
    // make sure we got an empty one at least - its all ints and its references from lots of templates
    if (usageMetrics == null) {
      usageMetrics = new NameUsageMetrics();
      usageMetrics.setKey(id);
    }
    // load checklist
    dataset = datasetService.get(usage.getDatasetKey());
    if (dataset == null) {
      throw new ReferentialIntegrityException(NameUsage.class, id, "Missing dataset " + usage.getDatasetKey());
    }

    // load constituent dataset too if we have one
    if (usage.getConstituentKey() != null) {
      constituent = datasetService.get(usage.getConstituentKey());
    }

    // load publisher
    publisher = organizationService.get(dataset.getOwningOrganizationKey());

    try {
      metrics = metricsService.get(usage.getDatasetKey());
    } catch (ServiceUnavailableException e) {
      LOG.error("Failed to load checklist metrics for dataset {}", usage.getDatasetKey());
    }

    try {
      numOccurrences = occurrenceCubeService.get(new ReadBuilder().at(OccurrenceCube.NUB_KEY, usage.getKey()));
      numGeoreferencedOccurrences =
        occurrenceCubeService.get(new ReadBuilder().at(OccurrenceCube.NUB_KEY, usage.getKey()).at(
          OccurrenceCube.IS_GEOREFERENCED, true));
    } catch (ServiceUnavailableException e) {
      LOG.error("Failed to load occurrence metrics for usage {}", usage.getKey(), e);
    }
  }

  public void setId(Integer id) {
    this.id = id;
  }

  /**
   * Populates the checklists map with the checklists for the given keys.
   * The method does not remove existing entries and can be called many times to add additional, new checklists.
   */
  protected void loadChecklists(Collection<UUID> checklistKeys) {
    for (UUID u : checklistKeys) {
      loadDataset(u);
    }
  }

  protected void loadDataset(UUID datasetKey) {
    if (datasetKey != null && !datasets.containsKey(datasetKey)) {
      try {
        datasets.put(datasetKey, datasetService.get(datasetKey));
      } catch (ServiceUnavailableException e) {
        LOG.error("Failed to load dataset with key {}", datasetKey);
        datasets.put(datasetKey, null);
      }
    }
  }

  public Dataset getConstituent() {
    return constituent;
  }

  public Organization getPublisher() {
    return publisher;
  }
}
