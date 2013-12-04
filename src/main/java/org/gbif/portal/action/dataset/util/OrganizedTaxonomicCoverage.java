package org.gbif.portal.action.dataset.util;

import java.util.ArrayList;
import java.util.List;
import javax.validation.constraints.NotNull;

/**
 * Class that conveniently stores all TaxonomicCoverage for a rank together. All TaxonomicCoverage are actually stored
 * as a list of DisplayableTaxonomicCoverage, that contains a display name for the TaxonomicCoverage.
 */
public class OrganizedTaxonomicCoverage {

  private String rank;
  private List<DisplayableTaxonomicCoverage> displayableNames = new ArrayList<DisplayableTaxonomicCoverage>();

  public OrganizedTaxonomicCoverage(String rank) {
    this.rank = rank;
  }

  /**
   * Get the rank.
   *
   * @return the rank
   */
  @NotNull
  public String getRank() {
    return rank;
  }

  /**
   * Set the rank.
   */
  public void setRank(String rank) {
    this.rank = rank;
  }

  /**
   * Get the list of DisplayableTaxonomicCoverage.
   *
   * @return the list of DisplayableTaxonomicCoverage
   */
  public List<DisplayableTaxonomicCoverage> getDisplayableNames() {
    return displayableNames;
  }

  /**
   * Set the list of DisplayableTaxonomicCoverage.
   */
  public void setDisplayableNames(List<DisplayableTaxonomicCoverage> displayableNames) {
    this.displayableNames = displayableNames;
  }
}
