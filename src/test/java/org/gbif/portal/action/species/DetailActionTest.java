package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.VernacularName;
import org.gbif.api.vocabulary.Language;
import org.gbif.portal.action.ActionTestUtil;

import java.util.List;

import com.google.common.collect.ImmutableList;
import org.apache.struts2.StrutsJUnit4TestCase;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;


public class DetailActionTest extends StrutsJUnit4TestCase<DetailAction> {

  // Utility builder
  private static VernacularName vernacularOf(String name, Language language, Boolean plural, Integer usageKey) {
    VernacularName n = new VernacularName();
    n.setVernacularName(name);
    n.setLanguage(language);
    n.setPlural(plural);
    n.setSourceTaxonKey(usageKey);
    return n;
  }

  private DetailAction action;

  @Before
  public void setup() {
    action = ActionTestUtil.initTestInjector().getInstance(DetailAction.class);
  }

  @Test
  public void testHabitats() throws Exception {
    assertNotNull(action);
    assertNotNull(action.getHabitats());
    assertEquals(0, action.getHabitats().size());
    action.appendHabitat(true, "enum.habitat.FRESHWATER");
    assertEquals(1, action.getHabitats().size());
    action.appendHabitat(false, "enum.habitat.TERRESTRIAL");
    assertEquals(2, action.getHabitats().size());
    action.appendHabitat(true, "THE_MOON");
    assertEquals(3, action.getHabitats().size());
    // surely we don't translate THE_MOON
    assertEquals("THE_MOON", action.getHabitats().get(2));
  }

  @Test
  public void testVernaculars() {
    List<VernacularName> source = ImmutableList.of(
      vernacularOf("Z", Language.ENGLISH, null, 1),
      vernacularOf("Z", null, null, 2),
      vernacularOf("A", Language.ABKHAZIAN, null, 3),
      vernacularOf("A", Language.ABKHAZIAN, true, 4),
      vernacularOf("B", Language.ABKHAZIAN, null, 5),
      vernacularOf("B", Language.GERMAN, null, 6),
      vernacularOf("B", null, null, 7),
      vernacularOf("b", Language.GERMAN, null, 8),
      vernacularOf("B", Language.GERMAN, null, null)
    );

    List<VernacularName> result = action.filterVernacularNames(source, Language.GERMAN);
    assertEquals(5, result.size());
    assertEquals(Language.GERMAN, result.get(0).getLanguage());
    assertEquals("B", result.get(0).getVernacularName());
    assertEquals(Language.ENGLISH, result.get(1).getLanguage());
  }
}
