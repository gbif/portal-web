package org.gbif.portal.action.dataset;

import org.gbif.api.model.registry.search.DatasetSearchResult;
import org.gbif.portal.action.ActionTestUtil;

import java.util.LinkedList;
import java.util.List;

import com.google.inject.Injector;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertFalse;
import static junit.framework.Assert.assertTrue;
import static org.junit.Assert.assertNotNull;

public class SearchActionTest {

  private static SearchAction sa;
  DatasetSearchResult result;

  @BeforeClass
  public static void first() {
    // initiate SearchAction
    Injector injector = ActionTestUtil.initTestInjector();
    sa = injector.getInstance(org.gbif.portal.action.dataset.SearchAction.class);
  }

  @Before
  public void setup() {
    // populate DatasetSearchResult without any highlighted fields
    result = populateTestDatasetSearchResult();
  }

  /**
   * The registry search module does many things at startup, including for example
   * pinging SOLR. This test simply ensures that this process works.
   */
  @Test
  public void test() {
    assertNotNull(sa);
  }

  @Test
  public void testAddMissingHighlighting() {
    assertEquals("<em class=\"gbifHl\">pon</em>taurus", sa.addMissingHighlighting("pontaurus", "pon"));
    assertEquals("<em class=\"gbifHl\">pon</em>taurus <em class=\"gbifHl\">pon</em>TAURUS",
      sa.addMissingHighlighting("pontaurus PONTAURUS", "pon"));
    assertEquals("Schulhof Gymnasium Hürth Bonn<em class=\"gbifHl\">strasse</em>",
      sa.addMissingHighlighting("Schulhof Gymnasium Hürth Bonnstrasse", "straße"));
    assertEquals(
      "<em class=\"gbifHl\">FADA Ephemeroptera: World checklist of freshwater Ephemeroptera species in the Catalogue of Life</em>",
      sa.addMissingHighlighting(
        "FADA Ephemeroptera: World checklist of freshwater Ephemeroptera species in the Catalogue of Life",
        "FADA Ephemeroptera: World checklist of freshwater Ephemeroptera species in the Catalogue of Life"));
  }

  @Test
  public void testAddMissingHighlightingNotApplied() {
    assertEquals("<em class=\"gbifHl\">pon</em>taurus",
      sa.addMissingHighlighting("<em class=\"gbifHl\">pon</em>taurus", "pon"));
    assertEquals("<em class=\"gbifHl\">pon</em>taurus",
      sa.addMissingHighlighting("<em class=\"gbifHl\">pon</em>taurus", ""));
    assertEquals("", sa.addMissingHighlighting("", "pon"));
  }

  @Test
  public void testFoldToAscii() throws Exception {
    assertEquals("strasse", sa.foldToAscii("straße"));
    assertEquals("strasse Imagenes", sa.foldToAscii("straße Imágenes"));
  }

  @Test
  public void testIsFullTextMatchOnly() {
    // there was no highlighting in any of the test object's fields, thereby it can be inferred that the match must have
// happened on full_text
    assertTrue(sa.isFullTextMatchOnly(result, "Pon"));
  }

  @Test
  public void testIsFullTextMatchOnlyFalse() {
    // override title with one that contains some (solr) highlighting
    result.setTitle("<em class=\"gbifHl\">Pon&lt;/em>Taurus collection");
    // there was no highlighting in any of the above fields, so infer match must have happened on full_text
    assertFalse(sa.isFullTextMatchOnly(result, "Pon"));
  }

  @Test
  public void testIsFullTextMatchOnlyForEmptyQueryText() {
    // there was no query text, and thus no match can be reported
    assertFalse(sa.isFullTextMatchOnly(result, ""));
  }

  /**
   * Create a test DatasetSearchResult populated without any (solr) highlighting.
   * 
   * @return populated test object
   */
  private DatasetSearchResult populateTestDatasetSearchResult() {
    DatasetSearchResult result = new DatasetSearchResult();
    result.setTitle("Title");
    result.setDescription("Desc");
    List<String> keywords = new LinkedList<String>();
    keywords.add("k1");
    result.setKeywords(keywords);
    result.setOwningOrganizationTitle("Owner");
    result.setHostingOrganizationTitle("Host");
    return result;
  }
}
