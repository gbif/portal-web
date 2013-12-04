package org.gbif.portal.config;

import org.gbif.api.vocabulary.Continent;
import org.gbif.api.vocabulary.Country;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.base.CharMatcher;
import com.google.common.base.Splitter;
import com.google.common.collect.FluentIterable;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Ordering;
import com.google.common.collect.Sets;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A utility class to map countries to specific drupal tag ids used in drupal news feeds for example.
 */
public class ContinentCountryMap {
  private static final Logger LOG = LoggerFactory.getLogger(ContinentCountryMap.class);
  private static final Splitter ROW_SPLITTER = Splitter.on(CharMatcher.WHITESPACE).trimResults().omitEmptyStrings();
  private final Map<Continent, List<Country>> continents = Maps.newHashMap();
  private final List<Continent> continentsSortedAlphabetically;

  /**
   * @param lines key=continent enum value, value=country iso code
   */
  public ContinentCountryMap(Set<String> lines) {
    Map<Continent, List<Country>> cm = Maps.newHashMap();
    for (String line : lines) {
      Iterator<String> cols = ROW_SPLITTER.split(line).iterator();

      Continent continent = Continent.fromString(cols.next());
      String iso = cols.next();
      Country c = Country.fromIsoCode(iso);
      if (c == null) {
        LOG.debug("Ignore unknown country {}", iso);
        continue;
      }
      if (!cm.containsKey(continent)) {
        cm.put(continent, Lists.<Country>newArrayList());
      }
      cm.get(continent).add(c);
    }
    // for checking if all countries are covered!
    Set<Country> countries = Sets.newHashSet();
    // sort countries into immutable list
    for (Continent c : cm.keySet()) {
      continents.put(c, FluentIterable.from(cm.get(c)).toSortedList(Ordering.natural()));
      countries.addAll(cm.get(c));
    }
    // check if all countries are covered!
    for (Country c : Country.values()) {
      if (c.isOfficial()) {
        if (!countries.contains(c)) {
          LOG.error("Country {} missing from continent country map!", c);
        }
      }
    }

    // continent enum is not sorted
    continentsSortedAlphabetically = ImmutableList.copyOf(Ordering.usingToString().sortedCopy(continents.keySet()));
  }

  public List<Continent> alphabeticallyOrderedContinents() {
    return continentsSortedAlphabetically;
  }

  public List<Country> listCountries(Continent c) {
    return continents.get(c);
  }
}
