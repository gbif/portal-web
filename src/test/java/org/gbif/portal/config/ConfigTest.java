package org.gbif.portal.config;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

public class ConfigTest {
  final String serverName = "http://staging32.gbiffy.orgo";

  @Test
  public void testBuildFromProperties() {
    Config cfg = Config.buildFromProperties();
    assertFalse(serverName.equals(cfg.getServerName()));
  }

  @Test
  public void testBuildFromPropertiesWithSystem() {
    // remember old setting
    final String oldSN = System.getProperty("servername");
    System.setProperty("servername", serverName);
    Config cfg = Config.buildFromProperties();
    assertEquals(serverName, cfg.getServerName());
    // reset to original - not sure if this setting stays between tests
    if (oldSN == null){
      System.clearProperty("servername");

    } else {
      System.setProperty("servername", oldSN);
    }
  }

}
