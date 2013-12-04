package org.gbif.portal.model;

import java.util.List;
import java.util.Map;

import com.google.common.collect.Maps;

/**
 * Utility class that holds the list of suggestions and replacements done for a scientific name search.
 * 
 * @param <T> suggestion type
 */
public class SearchSuggestions<T> {

  private Map<String, List<T>> suggestions;


  private Map<String, T> replacements;


  /**
   * Default constructor. Initializes the list of suggestion and replacements.
   */
  public SearchSuggestions() {
    suggestions = Maps.newHashMap();
    replacements = Maps.newHashMap();
  }


  /**
   * @return the replacements
   */
  public Map<String, T> getReplacements() {
    return replacements;
  }


  /**
   * @return the suggestions
   */
  public Map<String, List<T>> getSuggestions() {
    return suggestions;
  }


  /**
   * Determines if there are replacements available.
   */
  public boolean hasReplacements() {
    return !replacements.isEmpty();
  }


  /**
   * Determines if there are suggestions available.
   */
  public boolean hasSuggestions() {
    return !suggestions.isEmpty();
  }

  /**
   * @param replacements the replacements to set
   */
  public void setReplacements(Map<String, T> replacements) {
    this.replacements = replacements;
  }

  /**
   * @param suggestions the suggestions to set
   */
  public void setSuggestions(Map<String, List<T>> suggestions) {
    this.suggestions = suggestions;
  }

}
