package org.gbif.portal.action;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class BaseSearchActionTest {

  @Test
  public void testGetHighlightedText() throws Exception {
    assertEquals("hallo markus", BaseSearchAction.getHighlightedText("hallo markus", 20));
    assertEquals("hallo markus, hallo…", BaseSearchAction.getHighlightedText("hallo markus, hallo pia, hallo carla", 20));
    final String text = "Strings are constant; their values cannot be changed after they are created. String <em class=\"gbifHl\">buffers</em> support mutable strings. Because String objects are immutable they can be shared.";
    assertEquals("<em class=\"gbifHl\">buffers</em>", BaseSearchAction.getHighlightedText(text, 6));
    assertEquals("<em class=\"gbifHl\">buffers</em>", BaseSearchAction.getHighlightedText(text, 7));
    assertEquals("…<em class=\"gbifHl\">buffers</em> …", BaseSearchAction.getHighlightedText(text, 10));
    assertEquals("…g <em class=\"gbifHl\">buffers</em> supp…", BaseSearchAction.getHighlightedText(text, 16));
    assertEquals("…tring <em class=\"gbifHl\">buffers</em> support mutabl…", BaseSearchAction.getHighlightedText(text, 30));
    assertEquals("…created. String <em class=\"gbifHl\">buffers</em> support mutable strings. Because S…", BaseSearchAction.getHighlightedText(text, 60));
    assertEquals(text, BaseSearchAction.getHighlightedText(text, 200));

    final String text2 = "Strings are <em class=\"gbifHl\">constant</em>; their values cannot be changed after they are created. String buffers support mutable strings. Because String objects are immutable they can be shared.";
    assertEquals("…<em class=\"gbifHl\">constant</em>…", BaseSearchAction.getHighlightedText(text2, 10));
    assertEquals("Strings are <em class=\"gbifHl\">constant</em>; their values cannot be changed after they are created. St…", BaseSearchAction.getHighlightedText(text2, 80));
  }


  @Test
  public void testLimitHighlightedText() throws Exception {
    assertEquals("hall…", BaseSearchAction.limitHighlightedText("hallo markus", 5));
    assertEquals("hallo markus", BaseSearchAction.limitHighlightedText("hallo markus", 15));

    final String text = "String <em class=\"gbifHl\">buffers</em> support mutable strings.";
    assertEquals("String …", BaseSearchAction.limitHighlightedText(text, 8));
    assertEquals("String …", BaseSearchAction.limitHighlightedText(text, 12));
    assertEquals("String <em class=\"gbifHl\">buffers</em>…", BaseSearchAction.limitHighlightedText(text, 15));
    assertEquals("String <em class=\"gbifHl\">buffers</em> support mutabl…", BaseSearchAction.limitHighlightedText(text, 30));
    // Test addresses this issue: http://dev.gbif.org/issues/browse/PF-1247
    final String longText = "<em class=\"gbifHl\">FADA Ephemeroptera: World checklist of freshwater Ephemeroptera species in the Catalogue of Life</em>";
    assertEquals("<em class=\"gbifHl\">FADA Ephemeroptera: World checklist of freshwater…</em>", BaseSearchAction.limitHighlightedText(longText, 68));
  }
}
