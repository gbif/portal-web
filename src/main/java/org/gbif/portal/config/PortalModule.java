package org.gbif.portal.config;

import org.gbif.checklistbank.ws.client.guice.ChecklistBankWsClientModule;
import org.gbif.drupal.guice.DrupalMyBatisModule;
import org.gbif.metrics.ws.client.guice.MetricsWsClientModule;
import org.gbif.occurrence.query.TitleLookupModule;
import org.gbif.occurrence.ws.client.OccurrenceWsClientModule;
import org.gbif.registry.ws.client.guice.RegistryWsClientModule;
import org.gbif.utils.file.properties.PropertiesUtil;

import java.io.IOException;
import java.util.Properties;

import com.google.inject.AbstractModule;

public class PortalModule extends AbstractModule {

  @Override
  protected void configure() {
    try {
      Properties properties = PropertiesUtil.loadProperties(Config.APPLICATION_PROPERTIES);
      addWsUrls(properties);

      install(new PrivatePortalModule(properties));

      // bind registry API
      install(new RegistryWsClientModule(properties));

      // bind drupal mybatis services
      install(new DrupalMyBatisModule(properties));

      // bind checklist bank api. Select either the mybatis or the ws-client api implementation:
      install(new ChecklistBankWsClientModule(properties));

      // bind the occurrence (and occurrence download) service
      install(new OccurrenceWsClientModule(properties));

      // bind the metrics service
      install(new MetricsWsClientModule(properties));

      // bind the title lookup module needed for the human query builder
      install(new TitleLookupModule(true, properties.getProperty(Config.API_BASEURL_PROPERTY)));

    } catch (IllegalArgumentException e) {
      this.addError(e);
    } catch (IOException e) {
      this.addError(e);
    }
  }

  /**
   * Adds all required webservice url properties for all ws clients based on just the single api.baseurl.
   */
  private void addWsUrls(Properties properties) {
    final String api = properties.getProperty(Config.API_BASEURL_PROPERTY);
    properties.put("registry.ws.url", api);
    properties.put("checklistbank.ws.url", api);
    properties.put("checklistbank.match.ws.url", api+"/species/match");
    properties.put("occurrence.ws.url", api);
    properties.put("metrics.ws.url", api);
  }

}
