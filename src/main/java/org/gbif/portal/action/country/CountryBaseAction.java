package org.gbif.portal.action.country;

import org.gbif.api.model.checklistbank.DatasetMetrics;
import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.common.search.SearchResponse;
import org.gbif.api.model.metrics.cube.OccurrenceCube;
import org.gbif.api.model.metrics.cube.ReadBuilder;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.model.registry.search.DatasetSearchParameter;
import org.gbif.api.model.registry.search.DatasetSearchRequest;
import org.gbif.api.model.registry.search.DatasetSearchResult;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.occurrence.OccurrenceCountryIndexService;
import org.gbif.api.service.occurrence.OccurrenceDatasetIndexService;
import org.gbif.api.service.registry.DatasetSearchService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.NodeService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.vocabulary.Country;
import org.gbif.api.vocabulary.DatasetType;
import org.gbif.portal.action.node.NodeAction;
import org.gbif.portal.exception.NotFoundException;
import org.gbif.portal.model.CountWrapper;
import org.gbif.portal.model.CountryMetrics;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.google.common.collect.Lists;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CountryBaseAction extends NodeAction {

  private static Logger LOG = LoggerFactory.getLogger(CountryBaseAction.class);

  private String id;
  protected Country country;
  private CountryMetrics about;
  private CountryMetrics by;
  private final List<CountWrapper<Country>> countries = Lists.newArrayList();
  private PagingResponse<Country> countryPage;
  private PagingResponse<Dataset> datasetPage;

  protected OccurrenceDatasetIndexService datasetIndexService;
  protected OccurrenceCountryIndexService countryIndexService;
  protected DatasetService datasetService;
  protected DatasetSearchService datasetSearchService;

  @Inject
  public CountryBaseAction(NodeService nodeService, CubeService cubeService,
    OccurrenceDatasetIndexService datasetIndexService, OccurrenceCountryIndexService countryIndexService,
    DatasetService datasetService, DatasetSearchService datasetSearchService,
    DatasetMetricsService datasetMetricsService, OrganizationService organizationService) {
    super(nodeService, cubeService, datasetMetricsService, organizationService);
    this.datasetIndexService = datasetIndexService;
    this.countryIndexService = countryIndexService;
    this.datasetService = datasetService;
    this.datasetSearchService = datasetSearchService;
  }

  @Override
  public String execute() throws Exception {
    country = Country.fromIsoCode(id);
    if (country == null) {
      throw new NotFoundException("No country found with ISO code [" + id + ']');
    }

    member = nodeService.getByCountry(country);
    sortContacts();

    return SUCCESS;
  }

  public CountryMetrics getAbout() {
    return about;
  }

  public CountryMetrics getBy() {
    return by;
  }

  public List<CountWrapper<Country>> getCountries() {
    return countries;
  }

  public Country getCountry() {
    return country;
  }

  public PagingResponse<Country> getCountryPage() {
    return countryPage;
  }

  public String getIsocode() {
    return country.getIso2LetterCode();
  }

  @Override
  public void setId(String id) {
    this.id = id;
  }

  /**
   * Get a page of datasets. Used to display the list of occurrence datasets about Country.
   *
   * @return page of datasets
   */
  public PagingResponse<Dataset> getDatasetPage() {
    return datasetPage;
  }

  /**
   * populates the about field and optionally also loads the first requested datasets into the datasets property.
   * This allows to only call the index service once effectively and process its response.
   * 
   * @param numDatasetsToLoad number of datasets to load, if zero or negative doesnt load any
   */
  protected void buildAboutMetrics(int numDatasetsToLoad, int numCountriesToLoad) {
    // TODO: use checklist search to populate this???
    final long chkRecords = -1;
    final long chkDatasets = -1;
    final int organizations = -1;

    final long occRecords = cubeService.get(new ReadBuilder().at(OccurrenceCube.COUNTRY, country));

    final long occDatasets = loadAboutDatasetsPage(numDatasetsToLoad);

    // find number of external datasets
    DatasetSearchRequest search = new DatasetSearchRequest();
    search.addTypeFilter(DatasetType.METADATA);
    search.addCountryFilter(country);
    search.setLimit(0);
    SearchResponse<DatasetSearchResult, DatasetSearchParameter> resp = datasetSearchService.search(search);
    final long extDatasets = resp.getCount();

    int countryCount = loadCountryPage(true, numCountriesToLoad);

    about =
      new CountryMetrics(occDatasets, occRecords, chkDatasets, chkRecords, extDatasets, organizations, countryCount);
  }

  protected void buildByMetrics(int numDatasetsToLoad, int numCountriesToLoad) {
    final long occRecords = cubeService.get(new ReadBuilder().at(OccurrenceCube.HOST_COUNTRY, country));

    // we only want the counts here
    PagingRequest p = new PagingRequest(0, 0);
    final long occDatasets = datasetService.listByCountry(country, DatasetType.OCCURRENCE, p).getCount();
    final long chkDatasets = datasetService.listByCountry(country, DatasetType.CHECKLIST, p).getCount();
    final long extDatasets = datasetService.listByCountry(country, DatasetType.METADATA, p).getCount();
    final int organizations = -1;

    // for total checklist counts we need to retrieve the stats for every single checklist
    // we do not have a checklist cube yet
    long chkRecords = 0;
    p = new PagingRequest(0, 1000);  // there are only 100 checklists alltogether!
    for (Dataset chkl : datasetService.listByCountry(country, DatasetType.CHECKLIST, p).getResults()) {
      DatasetMetrics metric = datasetMetricsService.get(chkl.getKey());
      if (metric != null) {
        // count them all
        chkRecords += metric.getUsagesCount();
      }
    }

    // load full datasets preview if requested
    if (numDatasetsToLoad > 0) {
      p = new PagingRequest(0, numDatasetsToLoad);
      PagingResponse<Dataset> datasetPage = datasetService.listByCountry(country, null, p);
      super.loadCountWrappedDatasets(datasetPage);
    }

    int countryCount = loadCountryPage(false, numCountriesToLoad);

    by = new CountryMetrics(occDatasets, occRecords, chkDatasets, chkRecords, extDatasets, organizations, countryCount);
  }

  /**
   * Honors the offset paging parameter.
   * 
   * @return the number of all datasets having data about this country
   */
  protected int loadAboutDatasetsPage(int limit) {
    Map<UUID, Integer> dsMetrics = datasetIndexService.occurrenceDatasetsForCountry(country);
    int idx = 0;
    for (Map.Entry<UUID, Integer> metric : dsMetrics.entrySet()) {
      if (idx >= getOffset() + limit) {
        break;
      }
      // only load the requested page
      if (idx >= getOffset()) {
        Dataset d = datasetService.get(metric.getKey());
        if (d == null) {
          LOG.warn("Dataset in cube, but not in registry; {}", metric.getKey());

        } else {
          long total = cubeService.get(new ReadBuilder()
            .at(OccurrenceCube.DATASET_KEY, d.getKey()));
          datasets.add(new CountWrapper<Dataset>(d, metric.getValue(), total));
        }
      }
      idx++;
    }

    datasetPage = new PagingResponse<Dataset>(getOffset(), limit, (long) dsMetrics.size());

    return dsMetrics.size();
  }

  protected int loadCountryPage(boolean isAboutCountry, int limit) {
    try {
      Map<Country, Long> cMap;
      if (isAboutCountry) {
        cMap = countryIndexService.publishingCountriesForCountry(country);
      } else {
        cMap = countryIndexService.countriesForPublishingCountry(country);
      }

      countryPage = new PagingResponse<Country>(getOffset(), limit, (long) cMap.size());
      loadCountryList(cMap, isAboutCountry, limit);

      return cMap.size();

    } catch (RuntimeException e) {
      LOG.error("Cannot get country metrics", e);
    }
    return 0;
  }

  private void loadCountryList(Map<Country, Long> cMetrics, boolean isAboutCountry, int limit) {
    ReadBuilder rb = new ReadBuilder().at(OccurrenceCube.IS_GEOREFERENCED, true);
    if (isAboutCountry) {
      rb.at(OccurrenceCube.COUNTRY, country);
    } else {
      rb.at(OccurrenceCube.HOST_COUNTRY, country);
    }

    int idx = 0;
    for (Map.Entry<Country, Long> metric : cMetrics.entrySet()) {
      if (idx >= getOffset() + limit) {
        break;
      }

      // only load the requested page
      if (idx >= getOffset()) {
        if (isAboutCountry) {
          rb.at(OccurrenceCube.HOST_COUNTRY, metric.getKey());
        } else {
          rb.at(OccurrenceCube.COUNTRY, metric.getKey());
        }

        long geoCnt = cubeService.get(rb);
        countries.add(new CountWrapper<Country>(metric.getKey(), metric.getValue(), geoCnt));
      }

      idx++;
    }
  }
}
