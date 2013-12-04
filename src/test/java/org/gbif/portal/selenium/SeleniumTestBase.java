package org.gbif.portal.selenium;

import org.gbif.portal.config.Config;

import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.After;
import org.junit.Before;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.htmlunit.HtmlUnitDriver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Base class for Selenium test providing {@code Before} and {@code After} methods that set up a {@link HtmlUnitDriver}
 * and tears it down again.
 */
public abstract class SeleniumTestBase {

  protected final Logger LOG = LoggerFactory.getLogger(getClass());
  protected WebDriver driver;
  private final String baseUrl;
  private static final long DEFAULT_TIMEOUT = 30;
  private static final Pattern idLinkPattern = Pattern.compile("/([0-9]+)$");
  private static final Pattern jSessionIdPattern = Pattern.compile(";jsessionid(.)*$");

  protected SeleniumTestBase() {
    Config cfg = Config.buildFromProperties();
    baseUrl = cfg.getServerName();
  }

  @Before
  public void setUp() {
    LOG.info("Setting up html driver");
    driver = new HtmlUnitDriver();
    driver.manage().timeouts().implicitlyWait(DEFAULT_TIMEOUT, TimeUnit.SECONDS);
  }

  @After
  public void tearDown() {
    LOG.info("Tearing down html driver");
    if (driver != null) {
      driver.quit();
    }
  }

  /**
   * Instructs the driver to get the given URL and logs the html source.
   * @param url
   */
  protected void getUrl(String url){
    driver.get(url);
    LOG.debug("Page source retrieved for {}\n{}", url, driver.getPageSource());
  }

  protected Integer parseIdLink(String link) {
    Matcher matcher = jSessionIdPattern.matcher(link);
    link = matcher.replaceFirst("");
    Matcher m = idLinkPattern.matcher(link);
    if (m.find()) {
      return Integer.parseInt(m.group(1));
    }
    return null;
  }

  protected WebDriver getDriver() {
    return driver;
  }

  protected String getBaseUrl() {
    return baseUrl;
  }

  protected String getPortalUrl(String subpath) {
    return baseUrl + "/" + subpath;
  }

}
