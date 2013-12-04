package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.NameUsageContainer;
import org.gbif.api.model.checklistbank.VernacularName;
import org.gbif.api.vocabulary.Language;
import org.gbif.portal.action.ActionTestUtil;

import java.util.List;
import java.util.Map;

import com.google.common.collect.ImmutableList;
import org.apache.struts2.StrutsJUnit4TestCase;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;


public class DetailActionTest extends StrutsJUnit4TestCase<DetailAction> {

  // Utility builder
  private static VernacularName vernacularOf(String name, Language language, Boolean plural) {
    VernacularName n = new VernacularName();
    n.setVernacularName(name);
    n.setLanguage(language);
    n.setPlural(plural);
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
    action.appendHabitat(true, "enum.habitat.freshwater");
    assertEquals(1, action.getHabitats().size());
    action.appendHabitat(false, "enum.habitat.terrestrial");
    assertEquals(2, action.getHabitats().size());
    action.appendHabitat(true, "THE_MOON");
    assertEquals(3, action.getHabitats().size());
    // surely we don't translate THE_MOON
    assertEquals("THE_MOON", action.getHabitats().get(2));
  }

  @Test
  public void testVernaculars() {
    List<VernacularName> source = ImmutableList.of(
      vernacularOf("Z", Language.ENGLISH, null),
      vernacularOf("Z", null, null),
      vernacularOf("A", Language.ABKHAZIAN, null),
      vernacularOf("A", Language.ABKHAZIAN, true),
      vernacularOf("B", Language.ABKHAZIAN, null));
    action.usage = new NameUsageContainer();
    action.usage.setVernacularNames(source);
    action.populateVernacularNames();

    Map<String, List<VernacularName>> result = action.getVernacularNames();
    assertEquals(4, result.size());
    assertNotNull(result.get("a||ab")); // note that is lowercase
    assertEquals(2, result.get("a||ab").size());
  }
}
