package org.gbif.portal.action.occurrence.util;

import org.gbif.api.model.occurrence.Occurrence;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class MockOccurrenceFactoryTest {

  @Test
  public void testMock() {
    Occurrence mock = MockOccurrenceFactory.getMockOccurrence();
    assertEquals(String.valueOf(-1000000000), mock.getKey().toString());
    assertEquals(159, mock.getFields().size());
    assertEquals(6, mock.getIssues().size());
  }
}
