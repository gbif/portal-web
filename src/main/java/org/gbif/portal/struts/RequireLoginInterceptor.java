package org.gbif.portal.struts;

import org.gbif.api.model.common.User;
import org.gbif.portal.config.Constants;

import java.util.Map;

import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.AbstractInterceptor;

/**
 * An Interceptor that makes sure a user is currently logged in and returns a notLoggedIn otherwise.
 */
public class RequireLoginInterceptor extends AbstractInterceptor {

  @Override
  public String intercept(final ActionInvocation invocation) throws Exception {
    final Map session = invocation.getInvocationContext().getSession();
    final User user = (User) session.get(Constants.SESSION_USER);
    if (user != null) {
      return invocation.invoke();
    }
    return Constants.RESULT_LOGIN_REQUIRED;
  }

}
