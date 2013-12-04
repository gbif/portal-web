package org.gbif.portal.action.dataset;

import org.gbif.api.model.checklistbank.DatasetMetrics;
import org.gbif.api.model.metrics.cube.OccurrenceCube;
import org.gbif.api.model.metrics.cube.ReadBuilder;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.model.registry.Installation;
import org.gbif.api.model.registry.Organization;
import org.gbif.api.model.registry.eml.TaxonomicCoverage;
import org.gbif.api.model.registry.eml.TaxonomicCoverages;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.InstallationService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.vocabulary.Rank;
import org.gbif.portal.action.dataset.util.DisplayableTaxonomicCoverage;
import org.gbif.portal.action.dataset.util.OrganizedTaxonomicCoverage;
import org.gbif.portal.action.dataset.util.OrganizedTaxonomicCoverages;
import org.gbif.portal.action.member.MemberBaseAction;
import org.gbif.portal.action.member.MemberType;
import org.gbif.portal.exception.NotFoundException;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.UUID;

import javax.annotation.Nullable;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.CharMatcher;
import com.google.common.base.Strings;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A base action for common dataset pages.
 * TODO: This will be removed as there is no need for such hierarchy.
 */
@SuppressWarnings("serial")
public class DatasetBaseAction extends MemberBaseAction<Dataset> {

  private static final Logger LOG = LoggerFactory.getLogger(DatasetBaseAction.class);
  protected static final String EMPTY_RANK = "RANK_NOT_SPECIFIED";
  protected DatasetMetrics metrics;
  protected Installation installation;
  protected Organization publisher;
  protected Organization host;
  protected Dataset parentDataset;

  private List<OrganizedTaxonomicCoverages> organizedCoverages = Lists.newArrayList();
  @Nullable
  private Long numOccurrences;
  @Nullable
  private Long numGeoreferencedOccurrences;

  @Inject
  protected DatasetMetricsService metricsService;
  @Inject
  protected OrganizationService organizationService;
  @Inject
  protected InstallationService installationService;
  @Inject
  private CubeService occurrenceCubeService;

  protected DatasetService datasetService;

  public DatasetBaseAction(DatasetService datasetService, CubeService occurrenceCubeService,
    DatasetMetricsService metricsService, OrganizationService organizationService) {
    super(MemberType.DATASET, datasetService, occurrenceCubeService, metricsService, organizationService);
    this.datasetService = datasetService;
  }


  /**
   * @return true only if the string has content when trimmed
   */
  private static boolean hasNonWhitespace(final String s) {
    return !Strings.isNullOrEmpty(s) && !s.trim().isEmpty();
  }

  public Dataset getDataset() {
    return member;
  }

  public DatasetService getDatasetService() {
    return datasetService;
  }

  public Organization getHost() {
    return host;
  }

  @Override
  public UUID getId() {
    return id;
  }

  public Installation getInstallation() {
    return installation;
  }

  public DatasetMetrics getMetrics() {
    return metrics;
  }

  @Nullable
  public Long getNumGeoreferencedOccurrences() {
    return numGeoreferencedOccurrences;
  }

  @Nullable
  public Long getNumOccurrences() {
    return numOccurrences;
  }

  /**
   * @return the Dataset's taxonomic coverages organized by rank
   */
  public List<OrganizedTaxonomicCoverages> getOrganizedCoverages() {
    return organizedCoverages;
  }

  public Dataset getParentDataset() {
    return parentDataset;
  }

  public Organization getPublisher() {
    return publisher;
  }

  /**
   * Exposed to simplify Freemarker.
   */
  public Rank getSpeciesRank() {
    return Rank.SPECIES;
  }

  @Override
  public void setId(String id) {
    try {
      this.id = UUID.fromString(id);
    } catch (IllegalArgumentException e) {
      this.id = null;
    }
  }

  @Override
  protected void loadDetail() {
    if (id == null) {
      throw new NotFoundException("No identifier provided to load the dataset");
    }

    member = datasetService.get(id);
    if (member == null) {
      throw new NotFoundException("No dataset found with id " + id);
    }

    parentDataset = member.getParentDatasetKey() != null ? datasetService.get(member.getParentDatasetKey()) : null;

    publisher = member.getOwningOrganizationKey() != null ?
      organizationService.get(member.getOwningOrganizationKey()) : publisher;

    installation = installationService.get(member.getInstallationKey());

    host = organizationService.get(installation.getOrganizationKey());

    organizedCoverages = member.getTaxonomicCoverages() != null ?
      constructOrganizedTaxonomicCoverages(member.getTaxonomicCoverages()) : organizedCoverages;

    metrics = metricsService.get(id);
    if (metrics == null) {
      metrics = new DatasetMetrics();
    }

    populateOccurrenceCounts(); // only when a key exists
  }

  /**
   * Takes a list of the resource's TaxonomicCoverages, and for each one, creates a new OrganizedTaxonomicCoverage
   * that gets added to this class' list of OrganizedTaxonomicCoverage.
   * 
   * @param coverages list of resource's OrganizedTaxonomicCoverage
   */
  @VisibleForTesting
  List<OrganizedTaxonomicCoverages> constructOrganizedTaxonomicCoverages(List<TaxonomicCoverages> coverages) {
    List<OrganizedTaxonomicCoverages> organizedCoverages = new ArrayList<OrganizedTaxonomicCoverages>();
    for (TaxonomicCoverages coverage : coverages) {
      OrganizedTaxonomicCoverages organizedCoverage = new OrganizedTaxonomicCoverages();
      organizedCoverage.setDescription(coverage.getDescription());
      organizedCoverage.setCoverages(organizeTaxonomicCoverages(coverage.getCoverages()));
      organizedCoverages.add(organizedCoverage);
    }
    return organizedCoverages;
  }

  /**
   * Produces a list of rank names comprising the distinct uppercase values from the union of the {@link Rank} values
   * and the provided coverages.
   */
  @VisibleForTesting
  List<String> newRankList(List<TaxonomicCoverage> coverages) {
    LinkedHashSet<String> s = Sets.newLinkedHashSet();
    for (Rank rank : Rank.values()) {
      s.add(rank.name().toUpperCase());
    }
    for (TaxonomicCoverage cov : coverages) {
      if (cov.getRank() != null && hasNonWhitespace(cov.getRank().getVerbatim())) {
        s.add(cov.getRank().getVerbatim().toUpperCase().trim());
      }
    }
    // include "RANK NOT SPECIFIED" used to categorize coverages with no rank specified
    s.add(EMPTY_RANK);
    return ImmutableList.<String>copyOf(s);
  }

  /**
   * Construct the display name from TaxonomicCoverage's scientific name and common name properties. It will look like:
   * scientific name (common name) provided both properties are not null. Otherwise, it will be either the scientific
   * name or common name by themselves.
   * 
   * @return constructed display name or an empty string if none could be constructed
   */
  private String createDisplayNameForCoverage(TaxonomicCoverage coverage) {
    String combined = null;
    if (coverage != null) {

      String scientificName = hasNonWhitespace(coverage.getScientificName()) ?
        CharMatcher.WHITESPACE.trimFrom(coverage.getScientificName()) : null;

      String commonName = hasNonWhitespace(coverage.getCommonName()) ?
        CharMatcher.WHITESPACE.trimFrom(coverage.getCommonName()) : null;

      if (!Strings.isNullOrEmpty(scientificName) && !Strings.isNullOrEmpty(commonName)) {
        combined = scientificName + " (" + commonName + ")";
      } else if (scientificName != null) {
        combined = Strings.emptyToNull(scientificName);
      } else if (commonName != null) {
        combined = Strings.emptyToNull(commonName);
      }
    }
    return Strings.nullToEmpty(combined);
  }

  /**
   * This method iterates through a list of TaxonomicCoverage, and groups them all by rank. For each unique rank
   * represented in the list, there will be 1 OrganizedTaxonomicCoverage, that has a list of
   * DisplayableTaxonomicCoverage. A DisplayableTaxonomicCoverage is basically the same as TaxonomicCoverage, only that
   * it has a field called display name. The display name is the way the TaxonomicCoverage should be shown in the UI.
   * 
   * @param coverages list of TaxonomicCoverages' TaxonomicCoverage
   * @return list of OrganizedTaxonomicCoverage (one for each unique rank represented in the list of
   *         TaxonomicCoverage), or an empty list if none were added
   */
  private List<OrganizedTaxonomicCoverage> organizeTaxonomicCoverages(List<TaxonomicCoverage> coverages) {
    List<OrganizedTaxonomicCoverage> organizedTaxonomicCoveragesList = new ArrayList<OrganizedTaxonomicCoverage>();

    // create Rank name list, made from Rank vocab names + uninterpreted rank names discovered from coverages list
    List<String> rankNames = newRankList(coverages);

    for (String rankName : rankNames) {
      // initiate a new OrganizedTaxonomicCoverage for each rank
      OrganizedTaxonomicCoverage organizedCoverage = new OrganizedTaxonomicCoverage(rankName);

      // iterate through all coverages, and match all with same rank
      for (TaxonomicCoverage coverage : coverages) {
        // create display name
        String displayName = createDisplayNameForCoverage(coverage);
        // proceed if display name created (meaning coverage has at least a scientific name)
        if (!Strings.isNullOrEmpty(displayName)) {
          // Check if the interpreted rank or the verbatim rank matches.
          // Check for cases where there is no rank specified, only scientific name (grouped under RANK NOT SPECIFIED)
          Rank interpreted = coverage.getRank() == null ? null : coverage.getRank().getInterpreted();
          String verbatim = coverage.getRank() == null ? null : coverage.getRank().getVerbatim();
          if ((interpreted != null && rankName.equalsIgnoreCase(interpreted.name())) || (verbatim != null && rankName
            .equalsIgnoreCase(verbatim)) || (verbatim == null && interpreted == null && rankName
            .equalsIgnoreCase(EMPTY_RANK))) {
            // add DisplayableTaxonomicCoverage into OrganizedTaxonomicCoverage
            DisplayableTaxonomicCoverage displayable = new DisplayableTaxonomicCoverage(coverage, displayName);
            organizedCoverage.getDisplayableNames().add(displayable);
          }
        }
      }
      // add to list if OrganizedTaxonomicCoverage contained at least one DisplayableTaxonomicCoverage
      if (organizedCoverage.getDisplayableNames().size() > 0) {
        organizedTaxonomicCoveragesList.add(organizedCoverage);
      }
    }
    // return list
    return organizedTaxonomicCoveragesList;
  }

  /**
   * Populates the occurrence counts using the cube, only when the key exists.
   */
  private void populateOccurrenceCounts() {
    if (id != null) {
      try {
        numOccurrences = occurrenceCubeService.get(new ReadBuilder().at(OccurrenceCube.DATASET_KEY, id));
        numGeoreferencedOccurrences =
          occurrenceCubeService.get(new ReadBuilder().at(OccurrenceCube.DATASET_KEY, id).at(
            OccurrenceCube.IS_GEOREFERENCED, true));
      } catch (Exception e) {
        LOG.error("Failed to load occurrence metrics for dataset {}", id, e);
      }
    }
  }
}
