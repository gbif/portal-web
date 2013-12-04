package org.gbif.portal.config;

import org.gbif.api.vocabulary.Country;

import java.util.Map;

import com.google.common.collect.Maps;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A utility class to map countries to specific drupal tag ids used in drupal news feeds for example.
 */
public class DrupalCountryTagMap {
  private static final Logger LOG = LoggerFactory.getLogger(DrupalCountryTagMap.class);
  private Map<Country, Integer> map = Maps.newHashMap();

  /**
   * @param rawMap key=iso code, value=tag id
   */
  public DrupalCountryTagMap(Map<String, String> rawMap) {
    for (Map.Entry<String, String> ent : rawMap.entrySet()) {
      Country c = Country.fromIsoCode(ent.getKey());
      if (c != null) {
        map.put(c, Integer.parseInt(ent.getValue()));
      } else {
        LOG.debug("Ignore unknown drupal tag country {}", ent.getKey());
      }
    }
  }
  public Integer lookupTag(Country c) {
    return map.get(c);
  }
}
