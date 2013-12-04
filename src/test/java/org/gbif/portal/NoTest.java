package org.gbif.portal;

import org.junit.Test;

import static org.junit.Assert.assertTrue;

/**
 * Fake test that can be used to run integration tests quickly without running all unit tests beforehand.
 * For example to run a selenium test one can do:
 * mvn -Dtest=NoTest -Dit.test=SpeciesDetailSeleniumIT verify
 */
public class NoTest {

  @Test
  public void test() {
    assertTrue(true);
  }
}
