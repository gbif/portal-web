package org.gbif.portal.action;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

public class BaseActionTest {

  class TestAction extends BaseAction {
    
  }

  private BaseAction action = new TestAction();

  @Test
  public void testLink() throws Exception {
    assertNull(action.linkText(null));

    // unchanged
    verifyUnchanged("");
    verifyUnchanged(" ");
    verifyUnchanged("Ah, this is not a url. Is it? gbif.org/species");
    verifyUnchanged("Uhmm. <a href='www.gbif.org/species.'>bla bla bla</a>");
    verifyUnchanged("Ah, a url. <a href=\"https://www.gbif.org/species\">bla bla bla</a>.");
    verifyUnchanged("Ah, a url. <a href='http://www.gbif.org/species'>bla bla bla</a>.");
    verifyUnchanged("Ah, a url. <a href = 'http://www.gbif.org/species'>bla bla bla</a>.");
    verifyUnchanged("Ah, a url. <a target='blank'          \n     href   =   'http://www.gbif.org/species'>bla bla bla</a>.");
    verifyUnchanged("oha. <a href = 'http://dx.doi.org/10.1038/ng0609-637'>10.1038/ng0609-637</a>.");
    verifyUnchanged("oha. 10.1038-ng0609");
    verifyUnchanged("oha. 1.1038/ng0609");
    verifyUnchanged("oha. 10.abc/ng0609");
    verifyUnchanged("oha. 10.abc.ng");
    verifyUnchanged("oha. 10");
    verifyUnchanged("oha. 10.");
    verifyUnchanged("oha. 10.2113/ ");

    // added anchors
    assertEquals("Ah, a url. <a target='_blank' href='http://www.gbif.org/species'>www.gbif.org/species</a>", action.linkText(
      "Ah, a url. www.gbif.org/species"));
    assertEquals("Ah, a url. <a target='_blank' href='http://www.gbif.org/species'>http://www.gbif.org/species</a>.", action.linkText(
      "Ah, a url. http://www.gbif.org/species."));
    assertEquals("Ah, a url. <a target='_blank' href='https://www.gbif.org/species'>https://www.gbif.org/species</a>.", action.linkText(
      "Ah, a url. https://www.gbif.org/species."));
    assertEquals("Ah, a url. <a target='_blank' href='https://www.gbif.org/'>https://www.gbif.org/</a>\nspecies.", action.linkText(
      "Ah, a url. https://www.gbif.org/\nspecies."));
    assertEquals("Ah, a url. <a target='_blank' href='ftp://www.gbif.org/'>ftp://www.gbif.org/</a>\nspecies.", action.linkText(
      "Ah, a url. ftp://www.gbif.org/\nspecies."));

    final String in = "VIS - Fishes in estuarine waters in Flanders, <a href=\"http://localhost:8080/country/BE\">Belgium</a> is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO). The dataset contains over 70,000 fish occurrences sampled between 1992 and 2012 from almost 50 locations in the estuaries of the river Yser and the river Scheldt, in Flanders, <a href=\"http://localhost:8080/country/BE\">Belgium</a>. The dataset includes 115 fish species, as well as a number of non-target crustacean species. The data are retrieved from the Fish Information System (VIS), a database set up to monitor the status of fishes and their habitats in Flanders and are collected in support of the Water Framework Directive, the Habitat Directive, certain red lists, and biodiversity research. Additional information, such as measurements, absence information and abiotic data are available upon request. Issues with the dataset can be reported at https://github.com/LifeWatchINBO/vis-estuarine-occurrences";
    final String expected = "VIS - Fishes in estuarine waters in Flanders, <a href=\"http://localhost:8080/country/BE\">Belgium</a> is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO). The dataset contains over 70,000 fish occurrences sampled between 1992 and 2012 from almost 50 locations in the estuaries of the river Yser and the river Scheldt, in Flanders, <a href=\"http://localhost:8080/country/BE\">Belgium</a>. The dataset includes 115 fish species, as well as a number of non-target crustacean species. The data are retrieved from the Fish Information System (VIS), a database set up to monitor the status of fishes and their habitats in Flanders and are collected in support of the Water Framework Directive, the Habitat Directive, certain red lists, and biodiversity research. Additional information, such as measurements, absence information and abiotic data are available upon request. Issues with the dataset can be reported at <a target='_blank' href='https://github.com/LifeWatchINBO/vis-estuarine-occurrences'>https://github.com/LifeWatchINBO/vis-estuarine-occurrences</a>";
    assertEquals(expected, action.linkText(in));

    assertEquals("oha. <a target='_blank' href='http://doi.org/10.1038/ng0609-637'>doi:10.1038/ng0609-637</a> .", action.linkText("oha. doi:10.1038/ng0609-637 ."));
    assertEquals("oha. <a target='_blank' href='http://doi.org/10.1038/ng0609-637'>10.1038/ng0609-637</a> .", action.linkText("oha. 10.1038/ng0609-637 ."));
    assertEquals("oha. <a target='_blank' href='http://dx.doi.org/10.1038/ng0609-637'>http://dx.doi.org/10.1038/ng0609-637</a> .", action.linkText("oha. http://dx.doi.org/10.1038/ng0609-637 ."));
  }

  private void verifyUnchanged(String x) {
    assertEquals(x, action.linkText(x));
  }
}