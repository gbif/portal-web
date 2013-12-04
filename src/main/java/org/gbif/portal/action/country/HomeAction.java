package org.gbif.portal.action.country;

import org.gbif.api.service.registry.NodeService;
import org.gbif.api.vocabulary.Country;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.config.ContinentCountryMap;

import java.util.List;
import java.util.Set;
import javax.annotation.Nullable;

import com.google.common.base.Function;
import com.google.common.base.Predicate;
import com.google.common.collect.FluentIterable;
import com.google.common.collect.Lists;
import com.google.common.collect.Ordering;
import com.google.common.collect.Sets;
import com.google.inject.Inject;

public class HomeAction extends BaseAction {

  /**
   * Ensure we are ordered by title, removing noise.
   */
  private static List<Country> countries = FluentIterable.from(Lists.newArrayList(Country.values()))
    // remove unofficial countries
    .filter(new Predicate<Country>() {
      public boolean apply(@Nullable Country n) {
        return n.isOfficial();
      }
    })
    // sort alphabetically
    .toSortedList(Ordering.natural().onResultOf(new Function<Country, String>() {
      @Nullable
      @Override
      public String apply(@Nullable Country n) {
        return n == null ? null : n.getTitle();
      }
    }));

  private Set<Country> activeNodes;
  @Inject
  private NodeService nodeService;
  @Inject
  private ContinentCountryMap continentMap;

  @Override
  public String execute() throws Exception {
    activeNodes = Sets.newHashSet(nodeService.listActiveCountries());
    return SUCCESS;
  }

  public Set<Country> getActiveNodes() {
    return activeNodes;
  }

  public List<Country> getCountries() {
    return countries;
  }

}
