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
import static org.gbif.ws.paths.OccurrencePaths.COLLECTOR_NAME_PATH;
import static org.gbif.ws.paths.OccurrencePaths.INSTITUTION_CODE_PATH;
import static org.gbif.ws.paths.OccurrencePaths.OCC_SEARCH_PATH;

/**
 * Simple configuration bean to pass the guice binded properties on to the rendering layer.
 * When adding or modifying entries please also adjust the decorator default.ftl.
 */
public class Config {

  private static final Logger LOG = LoggerFactory.getLogger(Config.class);

  public static final String APPLICATION_PROPERTIES = "application.properties";
  private static final String STRUTS_PROPERTIES = "struts.properties";

  public static final String SERVERNAME = "servername";
  public static final String SUGGEST_PATH = "suggest";

  private static final String PROP_CONF_ERROR_MSG =
    "%s is no valid URL for property %s . Please configure application.properties appropriately!";

  private String googleAnalytics;
  private String drupal;
  private String drupalCookieName;
  private String serverName;
  private boolean includeContext;
  private String tileServerBaseUrl;
  private String wsClb;
  private String wsClbSearch;
  private String wsClbSuggest;
  private String wsOcc;
  private String wsOccCatalogNumberSearch;
  private String wsOccCollectorNameSearch;
  private String wsOccSearch;
  private String wsOccDownload;
  private String wsOccDownloadForPublicLink;
  private String wsReg;
  private String wsRegSearch;
  private String wsRegSuggest;
  private String wsMetrics;
  private String wsOccCollectionCodeSearch;
  private String wsOccInstitutionCodeSearch;
  private String wsImageCache;
  private Integer maxOccDowloadSize;
  private int maxOccSearchOffset;


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
      cfg.wsClb = getPropertyUrl(properties, "checklistbank.ws.url", true);
      final String clbSearchWs = getPropertyUrl(properties, "checklistbank.search.ws.url", true);
      cfg.wsClbSearch = clbSearchWs + "search";
      cfg.wsClbSuggest = clbSearchWs + "suggest";
      cfg.wsReg = getPropertyUrl(properties, "registry.ws.url", true);
      cfg.wsRegSearch = cfg.wsReg + "dataset/search";
      cfg.wsRegSuggest = cfg.wsReg + "dataset/suggest";
      cfg.wsOcc = getPropertyUrl(properties, "occurrence.ws.url", true);
      cfg.wsOccSearch = cfg.wsOcc + OCC_SEARCH_PATH;
      cfg.wsOccDownload = getPropertyUrl(properties, "occurrencedownload.ws.url", true);
      cfg.wsOccDownloadForPublicLink = getPropertyUrl(properties, "occurrencedownload.ws.url.for.public.link", true);
      cfg.maxOccDowloadSize = Integer.parseInt(properties.getProperty("occurrencedownload.size.limit"));
      cfg.maxOccSearchOffset = Integer.parseInt(properties.getProperty("occurrence.search.maxoffset"));
      cfg.wsMetrics = getPropertyUrl(properties, "metrics.ws.url", true);
      cfg.wsOccCatalogNumberSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + CATALOG_NUMBER_PATH;
      cfg.wsOccCollectorNameSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + COLLECTOR_NAME_PATH;
      cfg.wsOccCollectionCodeSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + COLLECTION_CODE_PATH;
      cfg.wsOccInstitutionCodeSearch = cfg.wsOcc + OCC_SEARCH_PATH + '/' + INSTITUTION_CODE_PATH;
      cfg.tileServerBaseUrl = getPropertyUrl(properties, "tile-server.url", false);
      cfg.wsImageCache = getPropertyUrl(properties, "image-cache.url", false);
      cfg.includeContext = Boolean.parseBoolean(properties.getProperty("struts.url.includeContext"));
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
    // prefer system variable if existing, required (e.g.) by selenim
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

  /**
   * @return the wsOccCollectionCodeSearch
   */
  public String getWsOccCollectionCodeSearch() {
    return wsOccCollectionCodeSearch;
  }

  public String getWsOccCollectorNameSearch() {
    return wsOccCollectorNameSearch;
  }

  public String getWsOccDownload() {
    return wsOccDownload;
  }

  /**
   * Get the occurrence download web service url that uses the public API used in links.
   * 
   * @return the occurrence download web service url that uses the public API
   */
  public String getWsOccDownloadForPublicLink() {
    return wsOccDownloadForPublicLink;
  }

  /**
   * @return the wsOccInstitutionCodeSearch
   */
  public String getWsOccInstitutionCodeSearch() {
    return wsOccInstitutionCodeSearch;
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

  public void setTileServerBaseUrl(String tileServerBaseUrl) {
    this.tileServerBaseUrl = tileServerBaseUrl;
  }

  public int getMaxOccSearchOffset() {
    return maxOccSearchOffset;
  }
}
