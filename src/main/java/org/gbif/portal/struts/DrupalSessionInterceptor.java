package org.gbif.portal.struts;

import org.gbif.api.model.common.User;
import org.gbif.api.service.common.UserService;
import org.gbif.drupal.mybatis.UserServiceImpl;
import org.gbif.portal.config.Config;

import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;

import com.google.inject.Inject;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;
import org.apache.struts2.StrutsStatics;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.gbif.portal.config.Constants.SESSION_USER;

/**
 * An interceptor that puts the current user into the session if its not yet existing and a request principle is given.
 */
public class DrupalSessionInterceptor extends AbstractInterceptor {

  private static final long serialVersionUID = 8383908769617385684L;

  private static final Logger LOG = LoggerFactory.getLogger(DrupalSessionInterceptor.class);

  private final UserServiceImpl userService;
  private final String COOKIE_NAME;
  private final String DRUPAL_SESSION_NAME = "drupal_session";

  @Inject
  public DrupalSessionInterceptor(UserService userService, Config cfg) {
    this.userService = (UserServiceImpl) userService;
    COOKIE_NAME = cfg.getDrupalCookieName();
  }

  @Override
  public String intercept(final ActionInvocation invocation) throws Exception {
    final Map session = invocation.getInvocationContext().getSession();
    final HttpServletRequest request =
      (HttpServletRequest) invocation.getInvocationContext().get(StrutsStatics.HTTP_REQUEST);
    final Cookie cookie = findDrupalCookie(request);

    // FOR DEBUGGING DURING DEVELOPMENT ONLY - you can switch a user without authenticating him!!!
    /*
     * if (!Strings.isNullOrEmpty(request.getParameter("DEBUG_USER"))) {
     * LOG.info("Force login for user {}", request.getParameter("DEBUG_USER"));
     * User user = userService.get(request.getParameter("DEBUG_USER"));
     * session.put(SESSION_USER, user);
     * session.put(DRUPAL_SESSION_NAME, "");
     * return invocation.invoke();
     * }
     */

    User user = (User) session.get(SESSION_USER);

    // invalidate current user if cookie is missing or drupal session is different
    if (user != null && (cookie == null || !cookie.getValue().equals(session.get(DRUPAL_SESSION_NAME)))) {
      LOG.info("Invalidate session for user {}", user.getUserName());
      user = null;
      session.clear();
    }

    if (user == null && cookie != null) {
      // user logged into drupal
      user = userService.getBySession(cookie.getValue());
      if (user == null) {
        LOG.warn("Drupal cookie contains invalid session {}", cookie.getValue());
      } else {
        session.put(SESSION_USER, user);
        session.put(DRUPAL_SESSION_NAME, cookie.getValue());
        LOG.info("Activate session {} for user {}", cookie.getValue(), user.getUserName());
      }
    }

    return invocation.invoke();
  }

  private Cookie findDrupalCookie(HttpServletRequest request) {
    if (request.getCookies() != null) {
      for (Cookie cookie : request.getCookies()) {
        if (COOKIE_NAME.equalsIgnoreCase(cookie.getName())) {
          return cookie;
        }
      }
    }
    return null;
  }

}
