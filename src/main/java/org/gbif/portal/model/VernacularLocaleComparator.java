package org.gbif.portal.model;

import org.gbif.api.model.checklistbank.VernacularName;
import org.gbif.api.vocabulary.Language;

import java.util.Comparator;

/**
 * Sorts by language first, then vernacular name itself, case insensitive.
 * Languages are sorted by locale first, then english, then all others alphabetically with null last.
 * TODO: move this comparator into the clb api
 */
public class VernacularLocaleComparator implements Comparator<VernacularName> {
  private static final int BEFORE = -1;
  private static final int AFTER = 1;

  private final Language locale;

  public VernacularLocaleComparator(Language locale) {
    this.locale = locale;
  }

  @Override
  public int compare(VernacularName v1, VernacularName v2) {
    if (v1.getLanguage() == v2.getLanguage()) {
      return v1.getVernacularName().compareToIgnoreCase(v2.getVernacularName());
    }

    if (locale != null && v1.getLanguage() == locale) {
      return BEFORE;
    } else if (locale != null && v2.getLanguage() == locale) {
      return AFTER;
    }

    if (v1.getLanguage() == Language.ENGLISH) {
      return BEFORE;
    } else if (v2.getLanguage() == Language.ENGLISH) {
      return AFTER;
    }

    return v1.getVernacularName().compareToIgnoreCase(v2.getVernacularName());
  }

  @Override
  public String toString() {
    return "VernacularLocaleComparator{" + locale + '}';
  }
}