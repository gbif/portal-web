package org.gbif.portal.config;

import javax.servlet.http.HttpSession;

import com.google.inject.AbstractModule;
import com.google.inject.Provides;

/**
 * Binds a http session for tests not using a container.
 */
public class TestServerMockModule extends AbstractModule {

  @Override
  protected void configure() {
  }

  @Provides
  public HttpSession provideHttpSession() {
    return null;
  }
}
