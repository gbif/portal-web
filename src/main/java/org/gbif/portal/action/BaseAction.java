package org.gbif.portal.action;

import org.gbif.api.model.common.User;
import org.gbif.portal.config.Config;
import org.gbif.portal.config.Constants;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URLEncoder;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.TreeMap;
import javax.annotation.Nullable;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

import com.google.common.base.Joiner;
import com.google.common.base.Predicate;
import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import com.opensymphony.xwork2.ActionSupport;
import org.apache.http.client.utils.URIUtils;
import org.apache.struts2.interceptor.ServletRequestAware;
import org.apache.struts2.interceptor.SessionAware;
import org.apache.struts2.util.ServletContextAware;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * A base class that provides accession to utilities for freemarker.
 */
@SuppressWarnings("serial")
public abstract class BaseAction extends ActionSupport
  implements SessionAware, ServletRequestAware, ServletContextAware {

  protected static Logger LOG = LoggerFactory.getLogger(BaseAction.class);
  private static Joiner QUERY_JOINER = Joiner.on('&');
  private static Splitter QUERY_SPLITTER = Splitter.on("&");

  protected Map<String, Object> session;
  protected HttpServletRequest request;
  protected ServletContext ctx;

  /**
   * The threshold that switches between 1px resolution and 4px resolution.
   */
  public static final int MAP_RESOLUTION_THRESHOLD = 50000;

  @Inject
  private Config cfg;

  /**
   * Checks whether a string starts with any of the prefixes specified
   *
   * @return true if string matches against any prefix. false otherwise.
   */
  private static boolean containsPrefix(String propertyKey, String[] prefixes) {
    if (propertyKey != null) {
      for (String prefix : prefixes) {
        if (propertyKey.startsWith(prefix)) {
          return true;
        }
      }
    }
    return false;
  }


  /**
   * Exposed to make configurations available to javascript.
   */
  public Config getCfg() {
    return cfg;
  }

  /**
   * Returns the application's base url. Exposed to simplify javascript.
   * It takes into account the includeContext struts settings to strip of the context if not used.
   *
   * @return the base url of the application
   */
  public String getBaseUrl() {
    if (cfg.isIncludeContext()) {
      return cfg.getServerName() + ctx.getContextPath();
    }
    return cfg.getServerName();
  }

  /**
   * Returns the absolute url to the current page including the query string.
   * Exposed to simplify freemarker and javascript.
   * It takes into account the includeContext struts settings to strip of the context if not used.
   *
   * @return the absolute, current url
   */
  public String getCurrentUrl() {
    return getCurrentUrl(false);
  }

  /**
   * Returns the absolute url to the current page including the query string, but having the paging
   * parameters offset and limit removed.
   * Exposed for the paging macros to not have to deal with this complexity in freemarker.
   */
  public String getCurrentUrlWithoutPage() {
    return getCurrentUrl(true);
  }

  /**
   * Used by the drupal login destination parameter which expects a relative URL of the current page.
   * We need to remove any scheme, host or port information and also the root slash.
   */
  public String getCurrentDestinationParam() {
    String url = getCurrentUrl();
    try {
      URI u = URI.create(url);
      return URIUtils.rewriteURI(u, null).toString().substring(1);

    } catch (Exception e) {
      LOG.warn("Cannot produce the login destination URL for {}", url);
      // return root if we ever should encounter an invalid URI
      return "/";
    }
  }

  private String getCurrentUrl(boolean removePagingParams) {
    StringBuffer currentUrl = request.getRequestURL();

    if (!cfg.isIncludeContext()) {
      // dont replace context name in host name
      final int start = currentUrl.indexOf(ctx.getContextPath(), cfg.getServerName().length()-1);
      currentUrl.replace(start, start+ctx.getContextPath().length(), "");
    }

    if (request.getQueryString() != null) {
      currentUrl.append("?");
      if (removePagingParams) {
        currentUrl.append(QUERY_JOINER.join(
          Iterables.filter(QUERY_SPLITTER.split(request.getQueryString()), new Predicate<String>() {
            @Override
            public boolean apply(@Nullable String input) {
              if (input.toLowerCase().startsWith("offset=") || input.toLowerCase().startsWith("limit=")) {
                return false;
              }
              return true;
            }
          })
        ));
      } else {
        currentUrl.append(request.getQueryString());
      }
    }
    return currentUrl.toString();
  }

  /**
   * @return the currently logged in user.
   */
  public User getCurrentUser() {
    return (User) session.get(Constants.SESSION_USER);
  }

  /**
   * Returns a map representing properties from the resource bundle but just those
   * properties whose keys match one or more of the given prefixes.
   *
   * @return a map which the matched properties
   */
  public Map<String, String> getResourceBundleProperties(String... prefix) {
    Map<String, String> bundleProps = new TreeMap<String, String>();
    ResourceBundle bundle = ResourceBundle.getBundle("resources", getLocale());
    // properties should be filtered out
    if (prefix != null && prefix.length != 0) {
      for (String key : bundle.keySet()) {
        // only add those properties whose key starts with one of the prefixes given
        if (containsPrefix(key, prefix)) {
          bundleProps.put(key, bundle.getString(key));
        }
      }
    } else { // just get all properties without any filtering at all
      for (String key : bundle.keySet()) {
        bundleProps.put(key, bundle.getString(key));
      }
    }
    return bundleProps;
  }

  protected HttpServletRequest getServletRequest() {
    return request;
  }

  /**
   * @return The HTTP session
   */
  protected Map<String, Object> getSession() {
    return session;
  }

  /**
   * @return true if an admin user is logged in
   */
  public boolean isAdmin() {
    return getCurrentUser() != null && getCurrentUser().isAdmin();
  }

  @Override
  public void setServletContext(ServletContext context) {
    this.ctx = context;
  }

  @Override
  public void setServletRequest(HttpServletRequest request) {
    this.request = request;
  }

  @Override
  public void setSession(Map<String, Object> session) {
    this.session = session;
  }

  public String getImageCache(String url, String size) {
    try {
      return cfg.getWsImageCache() + "?url=" + URLEncoder.encode(url, "utf8") + "&size=" + size;
    } catch (UnsupportedEncodingException e) {
      return cfg.getWsImageCache() + "?url=" + url + "&size=" + size;
    }
  }

  /**
   * A utility to provide the map resolution based on the provided record count.
   * 
   * @return the suggested resolution to use for the map.
   */
  public int getMapResolution(int recordCount) {
    return (recordCount > MAP_RESOLUTION_THRESHOLD) ? 1 : 4;
  }
}
