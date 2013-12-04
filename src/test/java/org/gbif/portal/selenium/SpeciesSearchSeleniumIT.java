package org.gbif.portal.selenium;

import java.util.LinkedList;

import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

public class SpeciesSearchSeleniumIT extends SeleniumTestBase {

  /**
   * @param name            the q name to search for
   * @param searchNub       true if only the nub is being searched, false to search all
   * @param expectedUsageId the list of expected name usage ids in the result, starting with first entry
   */
  private void assertNameSearch(String name, boolean searchNub, Integer expectedNumResults, int... expectedUsageId) {
    LOG.debug("Asserting name search '{}'", name);
    getUrl(getPortalUrl("species"));
    // Find input form and enter seach text
    WebElement input = driver.findElement(By.id("q"));
    input.sendKeys(name);
    LOG.debug("SEARCH FORM VALUE: {}", input.getAttribute("value"));
    driver.findElement(By.id("submitSearch")).click();

    // do we want a search across all checklists?
    if (!searchNub) {
      // TODO: doesnt seem to work. Maybe some javascript fix needed?
      driver.findElement(By.id("facetfilterDATASET_KEY")).findElement(By.cssSelector("a")).click();
    }

    // main content div on page
    WebElement content = driver.findElement(By.id("content"));

    // assert number of hits
    if (expectedNumResults != null) {
      assertEquals("Expected number of shown search results wrong", expectedNumResults,
        (Integer) content.findElements(By.cssSelector("div.result")).size());
    }

    // assert exact results
    LinkedList<WebElement> links = new LinkedList(content.findElements(By.cssSelector("div.result h2 a")));
    LOG.debug("{} search results found", links.size());
    for (int uid : expectedUsageId) {
      int speciesKey = parseIdLink(links.remove().getAttribute("href"));
      assertEquals("Expected result usage id different", uid, speciesKey);
    }
  }

  /**
   * This test uses the dataset page to search for all datasets, clicks on the second one and verifies that
   * the details page for the selected dataset is shown.
   */
  @Test
  public void testAvesSearch() {
    assertNameSearch("Aves", true, 20, 212);
    assertNameSearch("Aves", false, 20, 212);
    // assert first 10 hits are all Aves
    LinkedList<WebElement> titles = new LinkedList(driver.findElements(By.cssSelector("div.result h2 a strong")));
    for (WebElement t : titles) {
      // TODO: enable this once the remove nub facet click is working in assertNameSearch
      // LOG.info(t.getText());
      // assertTrue(t.getText().startsWith("Aves"));
    }
  }

  @Test
  public void testIdPattern() {
    assertEquals((Integer) 2685464, parseIdLink("http://staging.gbif.org:8080/portal-web-dynamic/species/2685464"));
    assertEquals((Integer) 212, parseIdLink("/portal-web-dynamic/species/212"));
    assertEquals((Integer) 1, parseIdLink("http://localhost:8080/species/1"));
    assertNull(parseIdLink("http://localhost:8080/species/search"));
  }

  /**
   * This test tries a species search with various names for the nub usage Abies pinsapo.
   */
  @Test
  public void testVernacularNameSearch() {
    assertNameSearch("Abies pinsapo", true, 17, 2685464);
    // TODO: vernacular nub names are currently not searchable: http://dev.gbif.org/issues/browse/CLB-163
    //assertNameSearch("Spanische", true, 11, 3898019);
  }

}
