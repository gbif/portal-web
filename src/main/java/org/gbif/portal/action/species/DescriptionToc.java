package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.Description;
import org.gbif.api.vocabulary.Language;

import java.util.List;
import java.util.Map;

import com.google.common.base.Strings;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

/**
 * Simple class wrapping all descriptions for a species and exposing methods used to generate a table of content menu.
 * This could become part of the regular CLB api at some point, but for now we use the basic listByUsage methods of
 * the DescriptionService to feed the ToC with full descriptions.
 */
public class DescriptionToc {

  private final Map<Language, Map<String, List<Integer>>> descriptionToc = Maps.newTreeMap();

  public void addDescription(Description description) {
    String topic = "general";
    if (!Strings.isNullOrEmpty(description.getType())) {
      topic = description.getType().toLowerCase();
    }

    Language lang;
    if (description.getLanguage() == null) {
      // default to english
      lang = Language.ENGLISH;
    } else {
      lang = description.getLanguage();
    }

    if (!descriptionToc.containsKey(lang)) {
      descriptionToc.put(lang, Maps.<String, List<Integer>>newTreeMap());
    }
    if (!descriptionToc.get(lang).containsKey(topic)) {
      descriptionToc.get(lang).put(topic, Lists.<Integer>newArrayList());
    }
    descriptionToc.get(lang).get(topic).add(description.getKey());
  }

  public boolean isEmpty() {
    return descriptionToc.isEmpty();
  }

  /**
   * @return list of all languages available for this ToC
   */
  public List<Language> listLanguages() {
    return Lists.newArrayList(descriptionToc.keySet());
  }

  /**
   * @return map of all topics for a given language with a list of description keys for each language
   */
  public Map<String, List<Integer>> listTopicEntries(Language lang) {
    if (descriptionToc.containsKey(lang)) {
      return descriptionToc.get(lang);
    }
    return Maps.newHashMap();
  }

}
