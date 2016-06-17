package org.gbif.portal.config;

import org.gbif.utils.file.properties.PropertiesUtil;

import java.io.IOException;
import java.net.URI;
import java.util.Properties;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.gbif.ws.paths.OccurrencePaths.CATALOG_NUMBER_PATH;
import static org.gbif.ws.paths.OccurrencePaths.COLLECTION_CODE_PATH;
import static org.gbif.ws.paths.OccurrencePaths.RECORDED_BY_PATH;
import static org.gbif.ws.paths.OccurrencePaths.INSTITUTION_CODE_PATH;
import static org.gbif.ws.paths.OccurrencePaths.OCC_SEARCH_PATH;
import static org.gbif.ws.paths.OccurrencePaths.RECORD_NUMBER_PATH;
import static org.gbif.ws.paths.OccurrencePaths.OCCURRENCE_ID_PATH;


/**
 * Simple configuration bean to pass the guice binded properties on to the rendering layer.
 * When adding or modifying entries please also adjust the decorator default.ftl.
 */
public class Config {

  private static final Logger LOG = LoggerFactory.getLogger(Config.class);

  public static final String APPLICATION_PROPERTIES = "application.properties";
  private static final String STRUTS_PROPERTIES = "struts.properties";
  public static final String API_BASEURL_PROPERTY = "api.baseurl";

  public static final String SERVERNAME = "servername";
  public static final String SUGGEST_PATH = "suggest";

  private static final String PROP_CONF_ERROR_MSG =
    "%s is no valid URL for property %s . Please configure application.properties appropriately!";

  private String googleAnalytics;
  private String drupal;
  private String drupalCookieName;
  private String serverName;
  private boolean includeContext;
  private String apiBaseUrl;
  private String tileServerBaseUrl;
  private String wsClb;
  private String wsClbSearch;
  private String wsClbSuggest;
  private String wsOcc;
  private String wsOccCatalogNumberSearch;
  private String wsOccCollectorNameSearch;
  private String wsOccRecordNumberSearch;
  private String wsOccSearch;
  private String wsReg;
  private String wsRegSearch;
  private String wsRegSuggest;
  private String wsMetrics;
  private String wsOccCollectionCodeSearch;
  private String wsOccInstitutionCodeSearch;
  private String wsOccurrenceIdSearch;
  private String annosysUrl;
  private String wsImageCache;
  private Integer maxOccDowloadSize;
  private int maxOccSearchOffset;

  //Used to enable/disable faceted search in the occurrence search page
  private boolean occurrenceFacetsEnabled;


  /**
   * To safeguard against configuration issues, this ensures that trailing slashes exist where required.
   * A future enhancement would be for those not to be required by the depending components, but currently
   * this is the state of affairs. This does at least help guard against incorrect use in the property
   * files.
   */
  public static Config buildFromProperties() {
    Config cfg = new Config();
    try {
      Properties properties = PropertiesUtil.loadProperties(APPLICATION_PROPERTIES);
      properties.putAll(PropertiesUtil.loadProperties(STRUTS_PROPERTIES));

      cfg.serverName = getServerName(properties);
      cfg.googleAnalytics = StringUtils.trimToNull(properties.getProperty("google.analytics"));
      cfg.drupal = getPropertyUrl(properties, "drupal.url", false);
      cfg.drupalCookieName = properties.getProperty("drupal.cookiename");
      cfg.maxOccDowloadSize = Integer.parseInt(properties.getProperty("occurrence.download.size.limit"));
      cfg.maxOccSearchOffset = Integer.parseInt(properties.getProperty("occurrence.search.maxoffset"));
      cfg.includeContext = Boolean.parseBoolean(properties.getProperty("struts.url.includeContext"));
      cfg.occurrenceFacetsEnabled = Boolean.parseBoolean(properties.getProperty("occurrence.facets.enable"));
      // API URLs
      cfg.apiBaseUrl = getPropertyUrl(properties, API_BASEURL_PROPERTY, true);
      cfg.wsClb = cfg.apiBaseUrl;
      cfg.wsClbSearch = cfg.wsClb + "species/search";
      cfg.wsClbSuggest = cfg.wsClb + "species/suggest";
      cfg.wsReg = cfg.apiBaseUrl;
      cfg.wsRegSearch = cfg.wsReg + "dataset/search";
      cfg.wsRegSuggest = cfg.wsReg + "dataset/suggest";
      cfg.wsOcc = cfg.apiBaseUrl;
      cfg.wsOccSearch = cfg.wsOcc + OCC_SEARCH_PATH;
      cfg.tileServerBaseUrl = cfg.apiBaseUrl + "map";
      cfg.wsImageCache = cfg.apiBaseUrl + "image";
      cfg.wsMetrics = cfg.apiBaseUrl;
      cfg.wsOccCatalogNumberSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + CATALOG_NUMBER_PATH;
      cfg.wsOccCollectorNameSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + RECORDED_BY_PATH;
      cfg.wsOccCollectionCodeSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + COLLECTION_CODE_PATH;
      cfg.wsOccInstitutionCodeSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + INSTITUTION_CODE_PATH;
      cfg.wsOccRecordNumberSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + RECORD_NUMBER_PATH;
      cfg.wsOccurrenceIdSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + OCCURRENCE_ID_PATH;;
      cfg.annosysUrl = getPropertyUrl(properties, "annosys.url", false);
    } catch (IOException e) {
      throw new ConfigurationException("application.properties cannot be read", e);
    }
    return cfg;
  }


  /**
   * Reads the property as a URL, and will optionally force a trailing slash as required by
   * http://dev.gbif.org/issues/browse/POR-260
   */
  private static String getPropertyUrl(Properties properties, String propName, boolean forceTrailingSlash) {
    String value = null;
    try {
      value = properties.getProperty(propName);
      value = (forceTrailingSlash && !value.endsWith("/")) ? value + '/' : value;
      URI uri = URI.create(value);
      return uri.toString();
    } catch (Exception e) {
      throw new ConfigurationException(String.format(PROP_CONF_ERROR_MSG, value, propName), e);
    }
  }

  /**
   * Gets the server name parameter from the properties.
   */
  private static String getServerName(Properties properties) {
    // prefer system variable if existing, required (e.g.) by selenium
    String serverName;
    try {
      serverName = URI.create(System.getProperty(SERVERNAME)).toString();
      LOG.debug("Using servername system variable");
    } catch (Exception e) {
      serverName = getPropertyUrl(properties, SERVERNAME, false);
    }
    LOG.debug("Setting servername to {}", serverName);
    return serverName;
  }

  public String getDrupal() {
    return drupal;
  }

  public String getDrupalCookieName() {
    return drupalCookieName;
  }

  public String getGoogleAnalytics() {
    return googleAnalytics;
  }

  /**
   * Maximum amount of records allowed in occurrence download file.
   * A negative value means that any size is allowed.
   */
  public Integer getMaxOccDowloadSize() {
    return maxOccDowloadSize;
  }

  public String getServerName() {
    return serverName;
  }

  /**
   * The base URL of the API, including latest version number. E.g. "http://api.gbif-dev.org/v0.9".
   *
   * @return base URL of the API
   */
  public String getApiBaseUrl() {
    return apiBaseUrl;
  }

  public String getTileServerBaseUrl() {
    return tileServerBaseUrl;
  }

  public String getWsClb() {
    return wsClb;
  }

  public String getWsClbSearch() {
    return wsClbSearch;
  }

  public String getWsClbSuggest() {
    return wsClbSuggest;
  }

  public String getWsImageCache() {
    return wsImageCache;
  }

  public String getWsMetrics() {
    return wsMetrics;
  }

  public String getWsOcc() {
    return wsOcc;
  }

  public String getWsOccCatalogNumberSearch() {
    return wsOccCatalogNumberSearch;
  }


  public String getWsOccRecordNumberSearch() {
    return wsOccRecordNumberSearch;
  }


  /**
   * @return the wsOccCollectionCodeSearch
   */
  public String getWsOccCollectionCodeSearch() {
    return wsOccCollectionCodeSearch;
  }

  public String getWsOccCollectorNameSearch() {
    return wsOccCollectorNameSearch;
  }

  /**
   * @return the wsOccInstitutionCodeSearch
   */
  public String getWsOccInstitutionCodeSearch() {
    return wsOccInstitutionCodeSearch;
  }

  public String getWsOccurrenceIdSearch() {
    return wsOccurrenceIdSearch;
  }

  public String getWsOccSearch() {
    return wsOccSearch;
  }

  public String getWsReg() {
    return wsReg;
  }

  public String getWsRegSearch() {
    return wsRegSearch;
  }

  public String getWsRegSuggest() {
    return wsRegSuggest;
  }


  public boolean isIncludeContext() {
    return includeContext;
  }

  public void setApiBaseUrl(String apiBaseUrl) {
    this.apiBaseUrl = apiBaseUrl;
  }

  public void setTileServerBaseUrl(String tileServerBaseUrl) {
    this.tileServerBaseUrl = tileServerBaseUrl;
  }

  public int getMaxOccSearchOffset() {
    return maxOccSearchOffset;
  }

  public String getAnnosysUrl() {
    return annosysUrl;
  }

  /**
   * Flag to enable/disable faceted search in the occurrence search page.
   */
  public boolean isOccurrenceFacetsEnabled() {
    return occurrenceFacetsEnabled;
  }

}
