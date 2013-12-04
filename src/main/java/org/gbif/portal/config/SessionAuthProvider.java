package org.gbif.portal.config;

import org.gbif.api.model.common.User;
import org.gbif.api.model.common.UserPrincipal;

import java.security.Principal;
import javax.servlet.http.HttpSession;

import com.google.inject.Inject;
import com.google.inject.Provider;
import com.google.inject.Singleton;

@Singleton
public class SessionAuthProvider implements Provider<Principal>{
  private static final String SESSION_USER = "current_user";
  private final Provider<HttpSession> sessionProvider;

  @Inject
  public SessionAuthProvider(Provider<HttpSession> sessionProvider) {
    this.sessionProvider = sessionProvider;
  }

  @Override
  public Principal get() {
    HttpSession session = sessionProvider.get();
    if (session != null && session.getAttribute(SESSION_USER) != null){
      return new UserPrincipal( (User) session.getAttribute(SESSION_USER) );
    }
    return null;
  }
}
