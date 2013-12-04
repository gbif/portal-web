package org.gbif.portal.model;

import org.gbif.api.model.checklistbank.VernacularName;
import org.gbif.api.vocabulary.Language;

import java.util.Collections;
import java.util.List;

import com.google.common.collect.Lists;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class VernacularLocaleComparatorTest {

  @Test
  public void testCompare() throws Exception {
    List<VernacularName> names = Lists.newArrayList();
    names.add( build(1,Language.GERMAN, "Tanne") );
    names.add( build(2,Language.DUTCH, "Tinne") );
    names.add( build(3,Language.DANISH, "tønne") );
    names.add( build(4,null, "tann") );
    names.add( build(5,Language.ENGLISH, "White fir") );
    names.add( build(6,null, "TANNENBAUM") );
    names.add( build(7,Language.ENGLISH, "FIR") );
    names.add( build(8,Language.AFRIKAANS, "dannebaum") );

    Collections.sort(names, new VernacularLocaleComparator(Language.GERMAN));
    assertEquals((Integer) 1, names.get(0).getKey());
    assertEquals((Integer) 7, names.get(1).getKey());
    assertEquals((Integer) 5, names.get(2).getKey());
    assertEquals((Integer) 8, names.get(3).getKey());
    assertEquals((Integer) 4, names.get(4).getKey());
    assertEquals((Integer) 6, names.get(5).getKey());
    assertEquals((Integer) 2, names.get(6).getKey());
    assertEquals((Integer) 3, names.get(7).getKey());

    Collections.sort(names, new VernacularLocaleComparator(Language.ENGLISH));
    assertEquals((Integer) 7, names.get(0).getKey());
    assertEquals((Integer) 5, names.get(1).getKey());
    assertEquals((Integer) 8, names.get(2).getKey());
    assertEquals((Integer) 4, names.get(3).getKey());
    assertEquals((Integer) 1, names.get(4).getKey());
    assertEquals((Integer) 6, names.get(5).getKey());
    assertEquals((Integer) 2, names.get(6).getKey());
    assertEquals((Integer) 3, names.get(7).getKey());

    Collections.sort(names, new VernacularLocaleComparator(null));
    assertEquals((Integer) 7, names.get(0).getKey());
    assertEquals((Integer) 5, names.get(1).getKey());
    assertEquals((Integer) 8, names.get(2).getKey());
    assertEquals((Integer) 4, names.get(3).getKey());
    assertEquals((Integer) 1, names.get(4).getKey());
    assertEquals((Integer) 6, names.get(5).getKey());
    assertEquals((Integer) 2, names.get(6).getKey());
    assertEquals((Integer) 3, names.get(7).getKey());
  }



  private VernacularName build(int key, Language lang, String name) {
    VernacularName v = new VernacularName();
    v.setKey(key);
    v.setLanguage(lang);
    v.setVernacularName(name);
    return v;
  }
}
