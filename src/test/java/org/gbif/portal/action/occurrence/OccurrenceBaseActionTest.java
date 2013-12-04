package org.gbif.portal.action.occurrence;

import java.util.Arrays;
import java.util.Collection;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import static junit.framework.Assert.assertEquals;

@RunWith(Parameterized.class)
public class OccurrenceBaseActionTest {

  private int year;
  private int month;
  private int day;
  private String expected;

  public OccurrenceBaseActionTest(String expected, int year, int month, int day) {
    this.expected = expected;
    this.year = year;
    this.month = month;
    this.day = day;
  }

  @Parameterized.Parameters
  public static Collection<Object[]> getInputParameters() {
    return Arrays.asList(new Object[][] {
      { "Oct 31, 2000", 2000, 10, 31},
      { "Dec 21, 1986", 1986, 12, 21},
      { "Oct, 2000", 2000, 10, 0 },
      { "2000", 2000, 0, 0}
      });
  }

  @Test
  public void testConstructPartialGatheringDate() {
    OccurrenceBaseAction action = new OccurrenceBaseAction();
    assertEquals(expected, action.constructPartialGatheringDate(year,  month, day));
  }
}
