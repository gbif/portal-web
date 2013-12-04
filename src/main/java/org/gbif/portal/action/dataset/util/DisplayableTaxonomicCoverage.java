package org.gbif.portal.action.dataset.util;

import org.gbif.api.model.registry.eml.TaxonomicCoverage;

import javax.validation.constraints.NotNull;

/**
 * Class that extends TaxonomicCoverage by adding a single property called displayName. This class is used to simplify
 * the display of taxon names, enabling the decision of how the name will be displayed in the Action, vs the template.
 * 
 * @see org.gbif.api.model.registry2.eml.TaxonomicCoverage
 */
public class DisplayableTaxonomicCoverage extends TaxonomicCoverage {

  /**
   * The display name.
   */
  private String displayName;

  public DisplayableTaxonomicCoverage(TaxonomicCoverage coverage, String displayName) {
    super(coverage.getScientificName(), coverage.getCommonName(), coverage.getRank());
    this.displayName = displayName;
  }

  /**
   * Gets the display name, produced by the concatenation of the scientific name and common name in parenthesis.
   * E.g. Plantae (plants)
   * 
   * @return the display name
   */
  @NotNull
  public String getDisplayName() {
    return displayName;
  }

  /**
   * Sets the display name.
   * 
   * @param displayName display name
   */
  public void setDisplayName(String displayName) {
    this.displayName = displayName;
  }
}
