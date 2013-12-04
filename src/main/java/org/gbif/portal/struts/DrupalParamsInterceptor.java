package org.gbif.portal.struts;

import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;
import org.apache.struts2.StrutsStatics;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * An Interceptor that detects the GBIF drupal multi-params format, and redirects them.
 * Drupal emits in the format ?COUNTRY=DK&COUNTRY-2=GB whereas we expect COUNTRY=DK&COUNTRY=GB.
 */
@SuppressWarnings("serial")
public class DrupalParamsInterceptor extends AbstractInterceptor {
  private static final Logger LOG = LoggerFactory.getLogger(DrupalParamsInterceptor.class);
  private static final String REPLACE_PATTERN = "-[\\d]+=";
  private static final String MATCH_PATTERN = ".+-[\\d]+$";

  @Override
  public String intercept(final ActionInvocation invocation) throws Exception {

    HttpServletRequest request = (HttpServletRequest) invocation.getInvocationContext().get(StrutsStatics.HTTP_REQUEST);
    HttpServletResponse response =
      (HttpServletResponse) invocation.getInvocationContext().get(StrutsStatics.HTTP_RESPONSE);

    @SuppressWarnings("unchecked")
    Enumeration<String> paramNames = request.getParameterNames();
    while (paramNames.hasMoreElements()) {
      String paramName = paramNames.nextElement();
      if (paramName.matches(MATCH_PATTERN)) {
        // rebuild the URL replacing the params
        String newURL = request.getRequestURL() + "?" + request.getQueryString().replaceAll(REPLACE_PATTERN, "=");
        LOG.info("Detected drupal format params.  Redirecting to {}", newURL);
        response.sendRedirect(newURL);
        return null;
      }
    }
    return invocation.invoke();
  }
}
