package org.gbif.portal.action.occurrence.util;

import org.gbif.api.model.occurrence.Download;
import org.gbif.api.model.occurrence.predicate.Predicate;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.occurrence.query.HumanFilterBuilder;
import org.gbif.occurrence.query.QueryParameterFilterBuilder;
import org.gbif.occurrence.query.TitleLookup;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.EnumSet;
import java.util.LinkedList;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.base.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Common utility functions for download actions.
 */
public class DownloadsActionUtils {

  private static final Pattern DATASET_FILTER_PATTERN = Pattern.compile("DATASET_?KEY=[0-9abcdef-]+&?", Pattern.CASE_INSENSITIVE);

  public static final EnumSet<Download.Status> RUNNING_STATUSES = EnumSet.of(Download.Status.PREPARING,
    Download.Status.RUNNING, Download.Status.SUSPENDED);

  private static final Logger LOG = LoggerFactory.getLogger(DownloadsActionUtils.class);

  /**
   * Private constructor.
   */
  private DownloadsActionUtils() {
    // Utility class must have private constructors only
  }

  public static boolean isRunning(Download download) {
    return RUNNING_STATUSES.contains(download.getStatus());
  }

  /**
   * Returns the human readable filter of an occurrence download.
   */
  public static Map<OccurrenceSearchParameter, LinkedList<String>> getHumanFilter(Predicate p, TitleLookup titleLookup) {
    if (p != null) {
      try {
        // not thread safe!
        HumanFilterBuilder builder = new HumanFilterBuilder(titleLookup);
        return builder.humanFilter(p);

      } catch (Exception e) {
        LOG.warn("Cannot create human representation for predicate {}", p);
      }
    }
    return null;
  }

  public static String getQueryParams(Predicate p) {
    if (p != null) {
      try {
        // not thread safe!
        QueryParameterFilterBuilder builder = new QueryParameterFilterBuilder();
        return builder.queryFilter(p);

      } catch (Exception e) {
        LOG.warn("Cannot create query parameter representation for predicate {}", p);
      }
    }
    return null;
  }

  public static String getQueryParamsWithoutDataset(Predicate p) {
    String query = DownloadsActionUtils.getQueryParams(p);
    if (!Strings.isNullOrEmpty(query)) {
      Matcher m = DATASET_FILTER_PATTERN.matcher(query);
      if (m.find()) {
        return m.replaceAll("");
      }
    }
    return query;
  }

  /**
   * Checks whether an available download URL actually dwcaExists by trying a http head request.
   */
  public static boolean dwcaExists(Download download){
    if (download == null || !download.isAvailable()) {
      return false;
    }
    try {
      URL url = new URL(download.getDownloadLink());
      HttpURLConnection con = (HttpURLConnection) url.openConnection();
      con.setInstanceFollowRedirects(false);
      con.setRequestMethod("HEAD");
      return con.getResponseCode() == HttpURLConnection.HTTP_OK;

    } catch (Exception e) {
      LOG.warn("Error testing download file existance {}", download.getDownloadLink(), e);
      return false;
    }
  }
}
