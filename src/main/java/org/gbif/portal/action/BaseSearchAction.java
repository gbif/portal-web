/*
 * Copyright 2011 Global Biodiversity Information Facility (GBIF)
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 */
package org.gbif.portal.action;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.common.search.SearchParameter;
import org.gbif.api.model.common.search.SearchRequest;
import org.gbif.api.model.common.search.SearchResponse;
import org.gbif.api.service.common.SearchService;
import org.gbif.api.util.VocabularyUtils;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.base.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * Class that encapsulates the basic functionality of free text search and paginated navigation.
 * The class expects a {@link SearchRequest} at creation time and delegates the parsing of search parameters to the
 * concrete subclass that needs to implement {@link #readFilterParams}.
 * 
 * @param <T> the content type of the results
 * @param <P> the search parameter enum
 * @param <R> the request type
 */
@SuppressWarnings("serial")
public abstract class BaseSearchAction<T, P extends Enum<?> & SearchParameter, R extends SearchRequest<P>>
  extends BaseAction {

  private static final Logger LOG = LoggerFactory.getLogger(BaseSearchAction.class);
  /**
   * Maximum # of characters shown in a highlighted field.
   */
  private static final String abrevMarker = "…";
  public static final String HL_PRE = "<em class=\"gbifHl\">";
  public static final String HL_POST = "</em>";
  public static final Pattern HL_MATCHER = Pattern.compile(HL_PRE + "([^<>]*)" + HL_POST, Pattern.CASE_INSENSITIVE);
  private static final int HL_MARKER_LENGTH = HL_PRE.length() + HL_POST.length();

  protected final Class<P> searchType;
  protected final SearchService<T, P, R> searchService;
  protected final R searchRequest;
  protected SearchResponse<T, P> searchResponse;
  protected String q;

  /**
   * Default constructor
   */
  public BaseSearchAction(SearchService<T, P, R> searchService, Class<P> searchType, R searchRequest) {
    this.searchService = searchService;
    this.searchType = searchType;
    this.searchRequest = searchRequest;
  }

  /**
   * Takes a highlighted text and trimmed it to show the first highlighted term.
   * The text is found using the HL_PRE and HL_POST tags.
   * Ensure that at least the whole term is shown or else MAX_LONG_HL_FIELD are displayed.
   * 
   * @param text highlighted text to be trimmed.
   * @param maxLength maximum length of resulting string, ignoring the highlighting tags
   * @return a trimmed version of the highlighted text
   */
  public static String getHighlightedText(String text, final int maxLength) {
    final int firstHlBeginTag = text.indexOf(HL_PRE);
    final int firstHlEndTag = text.indexOf(HL_POST) + HL_POST.length();
    final int hlTextSize = firstHlEndTag - firstHlBeginTag - HL_MARKER_LENGTH;
    // already smaller
    if (text.length() <= maxLength) {
      return text;
    }
    // no highlighted text, return first bit
    if (firstHlBeginTag < 0 || firstHlEndTag < 0) {
      return abbreviate(text, maxLength);
    }
    // highlighted text larger than max length - return it all to keep highlighting tags intact
    if (hlTextSize >= maxLength) {
      return text.substring(firstHlBeginTag, firstHlEndTag);
    }
    int sizeBefore = (maxLength - hlTextSize) / 3;
    int start = Math.max(0, firstHlBeginTag - sizeBefore);
    final String leftLimited = start == 0 ? text : abrevMarker + text.substring(start + (sizeBefore > 0 ? 1 : 0));
    return limitHighlightedText(leftLimited, maxLength);
  }

  /**
   * Used by UI to determine if a text is highlighted.
   * 
   * @param text
   * @return
   */
  public static boolean isHighlightedText(String text) {
    return !Strings.isNullOrEmpty(text) && text.contains(HL_PRE);
  }

  /**
   * Takes a highlighted text and returns the given number of initial characters, not counting html tags
   * and making sure we always keep html tags intact and closed.
   * 
   * @param highlightedText the highlighted text to be abbreviated
   * @return the beginning of the highlighted text up to a given number of characters
   */
  public static String limitHighlightedText(String highlightedText, int max) {
    StringBuffer sb = new StringBuffer();

    Matcher m = HL_MATCHER.matcher(highlightedText);
    int matched = 0;
    boolean appendTail = true;
    while (m.find()) {
      m.appendReplacement(sb, "");
      int currLength = sb.length() - matched * HL_MARKER_LENGTH;
      int hlLength = m.group(1).length();
      if (currLength + hlLength < max) {
        sb.append(m.group());
        matched++;
      } else {
        sb.append(abrevMarker);
        appendTail = false;
        break;
      }
    }
    if (appendTail) {
      m.appendTail(sb);
    }

    // Case where highlightedText wraps entire input string, and it exceeds the max length.
    // E.g. highlightedText = "<em class=\"gbifHl\">kyle</em>", and max length is 2.
    if (sb.toString().equals(abrevMarker) && highlightedText.startsWith(HL_PRE) && highlightedText.endsWith(HL_POST)
        && ((highlightedText.length() - HL_MARKER_LENGTH) > max)) {
      String txt = highlightedText.substring(HL_PRE.length(), highlightedText.indexOf(HL_POST));
      // if we're sure it doesn't contain other highlighting tags,
      // slide end tag backwards so highlighted text length = max length, then append "...", and closing tag
      if (!txt.contains(HL_PRE) && !txt.contains(HL_POST)) {
        return highlightedText.substring(0, max) + abrevMarker + HL_POST;
      }
    }

    return abbreviate(sb.toString(), max + matched * HL_MARKER_LENGTH);
  }

  /**
   * Takes a highlighted text and removes all tags used for highlighting.
   * 
   * @param highlightedText the highlighted text to be cleaned
   * @return a cleaned plain text version of the highlighted text
   */
  public static String removeHighlighting(String highlightedText) {
    return highlightedText.replaceAll(HL_PRE, "").replaceAll(HL_POST, "");
  }

  private static String abbreviate(String str, int maxWidth) {
    if (str == null) {
      return null;
    }
    if (maxWidth < 2) {
      throw new IllegalArgumentException("Minimum abbreviation width is 2");
    }
    if (str.length() <= maxWidth) {
      return str;
    }
    return str.substring(0, maxWidth - 1) + abrevMarker;
  }

  @Override
  public String execute() {
    LOG.info("Search for [{}]", getQ());
    // default query parameters
    searchRequest.setQ(getQ());
    // Turn off highlighting for empty query strings
    searchRequest.setHighlight(!Strings.isNullOrEmpty(q));
    // adds parameters processed by subclasses
    readFilterParams();
    // issues the search operation
    searchResponse = searchService.search(searchRequest);
    LOG.debug("Search for [{}] returned {} results", getQ(), searchResponse == null ? "null" : searchResponse.getCount());
    return SUCCESS;
  }

  /**
   * The input search pattern used to issue a search operation.
   * 
   * @return the q, input search pattern defaulting to "" if none is provided
   */
  public String getQ() {
    // To enable simple linking without a query as per http://dev.gbif.org/issues/browse/POR-274
    return (q == null) ? "" : q;
  }

  public P getSearchParam() {
    try {
      return (P) VocabularyUtils.lookupEnum("RANK", searchType);
    } catch (Exception e) {
      return null;
    }
  }

  /**
   * @param name
   * @return the search enum or null if it cant be converted
   */
  public P getSearchParam(String name) {
    try {
      return (P) VocabularyUtils.lookupEnum(name, searchType);
    } catch (Exception e) {
      return null;
    }
  }

  public R getSearchRequest() {
    return searchRequest;
  }

  /**
   * Response (containing the list of results) of the request issued.
   * 
   * @return the searchResponse
   * @see PagingResponse
   */
  public SearchResponse<T, P> getSearchResponse() {
    return searchResponse;
  }

  /**
   * Checks if a parameter value is already selected in the current request filters.
   * Public method used by html templates.
   * 
   * @param param the facet name according to
   */
  public boolean isInFilter(P param, String value) {
    if (param != null && searchRequest.getParameters().containsKey(param)) {
      for (String v : searchRequest.getParameters().get(param)) {
        if (v.equalsIgnoreCase(value)) {
          return true;
        }
      }
    }
    return false;
  }

  /**
   * Checks if a parameter value is already selected in the current request filters.
   * Public method used by html templates.
   * 
   * @param paramName the name according to
   */
  public boolean isInFilter(String paramName, String value) {
    return isInFilter(getSearchParam(paramName), value);
  }

  /**
   * Implement this method to parse the filter parameters from the request and populate the request parameters.
   * Make sure that empty parameters are set too to filter null values!
   */
  public void readFilterParams() {
    final Map<String, String[]> params = request.getParameterMap();

    for (String p : params.keySet()) {
      // recognize facets by enum name
      P param = getSearchParam(p);
      if (param != null) {
        // filter found
        for (String v : params.get(p)) {
          searchRequest.addParameter(param, translateFilterValue(param, v));
        }
      }
    }
  }

  /**
   * @param offset the offset to set
   * @see PagingRequest#setOffset(long)
   */
  public void setOffset(long offset) {
    this.searchRequest.setOffset(offset);
  }

  /**
   * @param q the input search pattern to set
   */
  public void setQ(String q) {
    this.q = Strings.nullToEmpty(q).trim();
  }

  /**
   * Optional hook for concrete search actions to define custom translations of filter values
   * before they are send to the search service.
   * For example to enable a simple checklist=nub filter without the need to know the real nub UUID.
   * The values will NOT be translated for the UI and request parameters, only for the search and title lookup service!
   * This method can be overriden to modify the returned value, by default it keeps it as it is.
   *
   * @param param the filter parameter the value belongs to
   * @param value the value to translate or return as is
   */
  protected String translateFilterValue(P param, String value) {
    // dont do anything by default
    return value;
  }


}
