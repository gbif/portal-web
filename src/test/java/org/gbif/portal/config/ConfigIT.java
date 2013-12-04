package org.gbif.portal.config;

import org.junit.Test;

public class ConfigIT {

  @Test
  public void testBuildFromProperties() {
    Config cfg = Config.buildFromProperties();
    System.out.println("ServerName: "+cfg.getServerName());
  }
}
