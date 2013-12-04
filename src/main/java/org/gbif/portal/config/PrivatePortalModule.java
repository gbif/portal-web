package org.gbif.portal.config;

import org.gbif.utils.file.FileUtils;
import org.gbif.ws.client.filter.HttpGbifAuthFilter;
import org.gbif.ws.client.guice.GbifApplicationAuthModule;
import org.gbif.ws.security.GbifAppAuthService;

import java.io.IOException;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import com.google.inject.Inject;
import com.google.inject.PrivateModule;
import com.google.inject.Provides;
import com.google.inject.Scopes;
import com.google.inject.Singleton;
import com.google.inject.name.Names;
import com.sun.jersey.api.client.filter.ClientFilter;

public class PrivatePortalModule extends PrivateModule{
  private final Properties properties;
  private final String appKey;
  private final String appSecret;

  public PrivatePortalModule(Properties properties) {
    this.properties = properties;
    this.appKey = properties.getProperty(GbifApplicationAuthModule.PROPERTY_APP_KEY);
    this.appSecret = properties.getProperty(GbifApplicationAuthModule.PROPERTY_APP_SECRET);
  }

  @Override
  protected void configure() {
    Names.bindProperties(binder(), properties);

    bind(SessionAuthProvider.class).in(Scopes.SINGLETON);

    expose(ClientFilter.class);
    expose(DrupalCountryTagMap.class);
    expose(ContinentCountryMap.class);
  }

  @Provides
  @Singleton
  public GbifAppAuthService provideGbifAppAuthService() {
    return new GbifAppAuthService(appKey, appSecret);
  }

  @Provides
  @Singleton
  @Inject
  public ClientFilter provideSessionAuthFilter(GbifAppAuthService authService, SessionAuthProvider sessionAuthProvider) {
    return new HttpGbifAuthFilter(appKey, authService, sessionAuthProvider);
  }

  @Provides
  @Singleton
  public DrupalCountryTagMap provideDrupalCountryTagMap() throws IOException {
    Map<String,String> rawMap = FileUtils.streamToMap(FileUtils.classpathStream("drupal_country_tags.txt"), 0, 1, true);
    return new DrupalCountryTagMap(rawMap);
  }

  @Provides
  @Singleton
  public ContinentCountryMap provideContinentCountryMap() throws IOException {
    Set<String> raw = FileUtils.streamToSet(FileUtils.classpathStream("country_by_continent.txt"));
    return new ContinentCountryMap(raw);
  }
}
