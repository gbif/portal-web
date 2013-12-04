package org.gbif.portal.action.member;

import org.gbif.api.model.checklistbank.DatasetMetrics;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.metrics.cube.OccurrenceCube;
import org.gbif.api.model.metrics.cube.ReadBuilder;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.model.registry.NetworkEntity;
import org.gbif.api.model.registry.Organization;
import org.gbif.api.model.registry.Tag;
import org.gbif.api.model.registry.Taggable;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.NetworkEntityService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.vocabulary.DatasetType;
import org.gbif.portal.exception.NotFoundException;
import org.gbif.portal.model.CountWrapper;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import com.google.common.base.Strings;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MemberBaseAction<T extends NetworkEntity & Taggable> extends org.gbif.portal.action.BaseAction {

  protected CubeService cubeService;
  protected DatasetMetricsService datasetMetricsService;
  protected OrganizationService organizationService;
  protected List<CountWrapper<Dataset>> datasets = Lists.newArrayList();
  protected UUID id;
  protected T member;
  private static final Logger LOG = LoggerFactory.getLogger(MemberBaseAction.class);
  private final NetworkEntityService<T> memberService;
  private final MemberType type;
  private List<String> keywords;
  private Map<UUID, Organization> orgMap = Maps.newHashMap();

  protected MemberBaseAction(MemberType type, NetworkEntityService<T> memberService,
    CubeService cubeService, DatasetMetricsService datasetMetricsService, OrganizationService organizationService) {
    this.memberService = memberService;
    this.type = type;
    this.cubeService = cubeService;
    this.datasetMetricsService = datasetMetricsService;
    this.organizationService = organizationService;
  }

  @Override
  public String execute() throws Exception {
    loadDetail();
    return SUCCESS;
  }

  public UUID getId() {
    return id;
  }

  /**
   * The member's list of lower cased, plain string keywords derived from public tags without a namespace.
   * This method loads keywords lazily.
   * @return member's list of keywords
   */
  public List<String> getKeywords() {
    if (keywords == null) {
      // lazy load keywords
      Set<String> kws = Sets.newTreeSet();
      for (Tag t : member.getTags()) {
        if (!Strings.isNullOrEmpty(t.getValue())) {
          kws.add(t.getValue().trim().toLowerCase());
        }
      }
      keywords = Lists.newArrayList(kws);
    }
    return keywords;
  }

  public T getMember() {
    return member;
  }

  public MemberType getType() {
    return type;
  }

  public void setId(String id) {
    try {
      this.id = UUID.fromString(id);
    } catch (IllegalArgumentException e) {
      this.id = null;
    }
  }

  protected void loadDetail() {
    LOG.debug("Getting detail for member key {}", id);
    member = memberService.get(id);
    if (member == null) {
      throw new NotFoundException("No member found with key " + id);
    }
  }

  /**
   * Loads list of CountWrapper Datasets, that is a list of datasets with a record count and a geo reference count
   * added to each one.
   *
   * @param datasetPage page of Datasets
   */
  protected void loadCountWrappedDatasets(PagingResponse<Dataset> datasetPage) {
    for (Dataset d : datasetPage.getResults()) {
      final long dsCnt;
      final long dsGeoCnt;
      if (DatasetType.OCCURRENCE == d.getType()) {
        dsCnt = cubeService.get(new ReadBuilder().at(OccurrenceCube.DATASET_KEY, d.getKey()));
        dsGeoCnt = cubeService.get(new ReadBuilder().at(OccurrenceCube.DATASET_KEY, d.getKey()).at(
          OccurrenceCube.IS_GEOREFERENCED, true));

      } else if (DatasetType.CHECKLIST == d.getType()) {
        DatasetMetrics metric = datasetMetricsService.get(d.getKey());
        dsCnt = (metric == null) ? 0 : metric.getUsagesCount();
        dsGeoCnt = 0;
      } else {
        dsCnt = 0;
        dsGeoCnt = 0;
      }

      datasets.add(new CountWrapper<Dataset>(d, dsCnt, dsGeoCnt));
    }
  }

  public List<CountWrapper<Dataset>> getDatasets() {
    return datasets;
  }

  /**
   * Utility method to access node infos using a small map cache.
   * Used in templates to show the publisher for datasets for example.
   */
  public Organization getOrganization(UUID key) {
    if (orgMap.containsKey(key)) {
      return orgMap.get(key);
    }
    Organization o = organizationService.get(key);
    orgMap.put(key, o);
    return o;
  }
}
