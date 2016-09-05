package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.NameUsage;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.service.occurrence.OccurrenceDatasetIndexService;
import org.gbif.api.vocabulary.DatasetType;

import java.util.SortedMap;
import java.util.UUID;

import com.google.common.collect.Lists;
import com.google.inject.Inject;

public class DatasetAction extends UsageBaseAction {

  public class DatasetResult implements Comparable<DatasetResult> {

    private final Dataset dataset;
    private final Integer numOccurrences;
    private final NameUsage usage;

    public DatasetResult(Dataset dataset, Integer numOccurrences, NameUsage usage) {
      this.dataset = dataset;
      this.numOccurrences = numOccurrences;
      this.usage = usage;
    }

    @Override
    public int compareTo(DatasetResult that) {
      if (this == that) {
        return 0;
      }
      return dataset.getTitle().toLowerCase().compareTo(that.getDataset().getTitle().toLowerCase());
    }

    public Dataset getDataset() {
      return dataset;
    }

    public Integer getNumOccurrences() {
      return numOccurrences;
    }

    public NameUsage getUsage() {
      return usage;
    }
  }

  @Inject
  private OccurrenceDatasetIndexService occurrenceDatasetService;
  private DatasetType type;
  private PagingResponse<DatasetResult> page;
  private int offset = 0;

  private static final int pageSize = 25;

  @Override
  public String execute() {
    loadUsage();

    page = new PagingResponse<DatasetResult>(offset, pageSize);
    long count = 0;
    if (type == null || type == DatasetType.CHECKLIST) {
      PagingResponse<NameUsage> resp = usageService.listRelated(usage.getNubKey(), getLocale(), page);
      count = resp.getCount();
      for (NameUsage u : resp.getResults()) {
        // remove nub usage itself
        if (!u.getKey().equals(usage.getKey())) {
          page.getResults().add(new DatasetResult(datasetService.get(u.getDatasetKey()), null, u));
        } else {
          count--;
        }
      }
    }

    if ((type == null || type == DatasetType.OCCURRENCE) && usage.getNubKey() != null) {
      SortedMap<UUID, Integer> occurrenceDatasetCounts = occurrenceDatasetService.occurrenceDatasetsForNubKey(usage.getNubKey());
      count += occurrenceDatasetCounts.size();
      for (UUID uuid : sublist(Lists.newArrayList(occurrenceDatasetCounts.keySet()), offset, offset + pageSize)) {
        page.getResults().add(new DatasetResult(datasetService.get(uuid), occurrenceDatasetCounts.get(uuid), null));
      }
    }

    page.setCount(count);
    return SUCCESS;
  }

  public int getOffset() {
    return offset;
  }

  public PagingResponse<DatasetResult> getPage() {
    return page;
  }

  public DatasetType getType() {
    return type;
  }

  public void setOffset(int offset) {
    this.offset = offset;
  }

  public void setType(DatasetType type) {
    this.type = type;
  }
}
