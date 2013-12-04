package org.gbif.portal.model;

import com.google.common.collect.Lists;
import org.junit.Test;

import static junit.framework.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class CountWrapperTest {
  CountWrapper<String> cw1 = new CountWrapper<String>("Tim", 10);
  CountWrapper<String> cw2 = new CountWrapper<String>("Timmy", 20);
  CountWrapper<String> cw3 = new CountWrapper<String>("Timo", 31);
  CountWrapper<String> cw1b = new CountWrapper<String>("Tim", 10);
  CountWrapper<String> cw1c = new CountWrapper<String>("Tim", 1);
  CountWrapper<String> cw1d = new CountWrapper<String>("Tim", 10, 8);

  @Test
  public void testSum() throws Exception {
    assertEquals(61l, CountWrapper.sum(Lists.newArrayList(cw1, cw2, cw3)));
  }

  @Test
  public void testCompareTo() throws Exception {
    for (CountWrapper cw : Lists.newArrayList(cw1, cw2, cw1b, cw1c, cw1d)) {
      assertTrue(cw3.compareTo(cw) > 0);
    }
    for (CountWrapper cw : Lists.newArrayList(cw1, cw2, cw1b, cw3, cw1d)) {
      assertTrue(cw1c.compareTo(cw) < 0);
    }
    assertEquals(0, cw1.compareTo(cw1b));
  }

  @Test
  public void testEquals() throws Exception {
    assertTrue(cw1.equals(cw1b));
    assertFalse(cw1.equals(cw1c));
    assertFalse(cw1.equals(cw1d));
    assertFalse(cw1.equals(cw2));
    assertFalse(cw1.equals(cw3));
  }
}
