package org.gbif.portal.model;

import org.gbif.api.model.common.search.Facet;


/**
 * Extended facet count with an additional optional title field
 * that can be used to display other values than the facet being used in solr.
 * This allows facets to be keys only while the title can be used to show real names.
 */
public class FacetInstance extends Facet.Count {

  private String title;

  public FacetInstance() {
  }

  public FacetInstance(Facet.Count c) {
    super(c.getName(), c.getCount());
  }

  public FacetInstance(String name) {
    super(name, null);
  }

  public FacetInstance(String name, String title, Long count) {
    super(name, count);
    this.title = title;
  }

  /**
   * @return the title to display, defaulting to name in case its null.
   */
  public String getTitle() {
    return title == null ? getName() : title;
  }

  public void setTitle(String title) {
    this.title = title;
  }
}
