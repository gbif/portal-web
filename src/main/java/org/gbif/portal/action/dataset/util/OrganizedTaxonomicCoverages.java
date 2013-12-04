package org.gbif.portal.action.dataset.util;

import java.util.List;

/**
 * Class similar to TaxonomicCoverages, but the list of TaxonomicCoverage are OrganizedTaxonomicKeywords.
 *
 * @see org.gbif.api.model.registry2.eml.TaxonomicCoverages
 */
public class OrganizedTaxonomicCoverages {

  private List<OrganizedTaxonomicCoverage> coverages;
  private String description;

  /**
   * Get the description.
   *
   * @return the description
   */
  public String getDescription() {
    return description;
  }

  /**
   * Set the description.
   *
   * @param description the description
   */
  public void setDescription(String description) {
    this.description = description;
  }

  /**
   * Get the list of OrganizedTaxonomicCoverage.
   *
   * @return the list of OrganizedTaxonomicCoverage
   */
  public List<OrganizedTaxonomicCoverage> getCoverages() {
    return coverages;
  }

  /**
   * Set the list of OrganizedTaxonomicCoverage.
   *
   * @param coverages the list of OrganizedTaxonomicCoverage
   */
  public void setCoverages(List<OrganizedTaxonomicCoverage> coverages) {
    this.coverages = coverages;
  }
}
