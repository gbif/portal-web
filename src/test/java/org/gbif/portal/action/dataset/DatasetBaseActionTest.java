package org.gbif.portal.action.dataset;

import org.gbif.api.model.common.InterpretedEnum;
import org.gbif.api.model.registry.eml.TaxonomicCoverage;
import org.gbif.api.model.registry.eml.TaxonomicCoverages;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.vocabulary.Rank;
import org.gbif.portal.action.dataset.util.DisplayableTaxonomicCoverage;
import org.gbif.portal.action.dataset.util.OrganizedTaxonomicCoverage;
import org.gbif.portal.action.dataset.util.OrganizedTaxonomicCoverages;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

import static junit.framework.Assert.assertEquals;
import static org.mockito.Mockito.mock;

public class DatasetBaseActionTest {

  @Test
  public void testPopulateOrganizedCoverages() {
    DatasetBaseAction action = new DatasetBaseAction(mock(DatasetService.class),
      mock(CubeService.class), mock(DatasetMetricsService.class), mock(OrganizationService.class));

    // create coverages #1
    TaxonomicCoverages coverages1 = new TaxonomicCoverages();
    List<TaxonomicCoverages> coveragesList = new ArrayList<TaxonomicCoverages>();

    TaxonomicCoverage coverage1 = new TaxonomicCoverage();
    coverage1.setCommonName("Plants");
    coverage1.setScientificName("Plantae");
    coverage1.setRank(new InterpretedEnum("kingdom", Rank.KINGDOM));


    TaxonomicCoverage coverage2 = new TaxonomicCoverage();
    coverage2.setCommonName("Animals");
    coverage2.setScientificName("Animalia");
    coverage2.setRank(new InterpretedEnum("kingdom", Rank.KINGDOM));

    List<TaxonomicCoverage> coverageList = new ArrayList<TaxonomicCoverage>();
    coverageList.add(coverage1);
    coverageList.add(coverage2);

    coverages1.setCoverages(coverageList);
    coverages1.setDescription("Coverages #1 description");

    coveragesList.add(coverages1);

    // create coverages #2
    TaxonomicCoverages coverages2 = new TaxonomicCoverages();

    TaxonomicCoverage coverage_2_1 = new TaxonomicCoverage();
    coverage_2_1.setScientificName("Equisetophyta");
    coverage_2_1.setRank(new InterpretedEnum("phylum", Rank.PHYLUM));

    TaxonomicCoverage coverage_2_2 = new TaxonomicCoverage();
    coverage_2_2.setScientificName("Pteridophyta");
    coverage_2_2.setRank(new InterpretedEnum("phylum", Rank.PHYLUM));

    TaxonomicCoverage coverage_2_3 = new TaxonomicCoverage();
    coverage_2_3.setScientificName("Pteridophyta");
    coverage_2_3.setRank(new InterpretedEnum("FEYELUM", null));

    // only having scientific name
    TaxonomicCoverage coverage_2_4 = new TaxonomicCoverage();
    coverage_2_4.setScientificName("Euphyllophytina");

    List<TaxonomicCoverage> coverageList2 = new ArrayList<TaxonomicCoverage>();
    coverageList2.add(coverage_2_1);
    coverageList2.add(coverage_2_2);
    coverageList2.add(coverage_2_3);
    coverageList2.add(coverage_2_4);

    coverages2.setCoverages(coverageList2);
    coverages2.setDescription("Coverages #2 description");

    // add 2 coverages to list
    coveragesList.add(coverages2);

    // return organized coverages
    List<OrganizedTaxonomicCoverages> organizedCoverages = action.constructOrganizedTaxonomicCoverages(coveragesList);

    // assert some things about 1st coverages
    assertEquals("Coverages #1 description", organizedCoverages.get(0).getDescription());

    OrganizedTaxonomicCoverage organizedCoverage = organizedCoverages.get(0).getCoverages().get(0);
    assertEquals(2, organizedCoverage.getDisplayableNames().size());

    DisplayableTaxonomicCoverage displayableCoverage1 = organizedCoverage.getDisplayableNames().get(0);
    assertEquals("Plantae (Plants)", displayableCoverage1.getDisplayName());
    assertEquals("Plantae", displayableCoverage1.getScientificName());
    assertEquals("Plants", displayableCoverage1.getCommonName());

    DisplayableTaxonomicCoverage displayableCoverage2 = organizedCoverage.getDisplayableNames().get(1);
    assertEquals("Animalia (Animals)", displayableCoverage2.getDisplayName());
    assertEquals("Animalia", displayableCoverage2.getScientificName());
    assertEquals("Animals", displayableCoverage2.getCommonName());

    // assert some things about 2nd coverages
    assertEquals("Coverages #2 description", organizedCoverages.get(1).getDescription());
    // assert there is an OrganizedTaxonomicCoverage for each unique Rank encountered in TaxonomicCoverage list
    assertEquals(3, organizedCoverages.get(1).getCoverages().size());

    // check OrganizedTaxonomicCoverage
    OrganizedTaxonomicCoverage organizedCoverage2_1 = organizedCoverages.get(1).getCoverages().get(0);
    assertEquals(2, organizedCoverage2_1.getDisplayableNames().size());
    assertEquals("PHYLUM", organizedCoverages.get(1).getCoverages().get(0).getRank());

    // check OrganizedTaxonomicCoverage for verbatim, uninterpreted Rank called FEYELUM
    OrganizedTaxonomicCoverage organizedCoverage2_2 = organizedCoverages.get(1).getCoverages().get(1);
    assertEquals(1, organizedCoverage2_2.getDisplayableNames().size());
    assertEquals("FEYELUM", organizedCoverage2_2.getRank());

    // check OrganizedTaxonomicCoverage for coverage having no rank, only scientific name
    OrganizedTaxonomicCoverage organizedCoverage2_3 = organizedCoverages.get(1).getCoverages().get(2);
    assertEquals(1, organizedCoverage2_3.getDisplayableNames().size());
    assertEquals("Euphyllophytina", organizedCoverage2_3.getDisplayableNames().get(0).getScientificName());
  }

}
