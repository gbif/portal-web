package org.gbif.portal;

import org.gbif.api.vocabulary.BasisOfRecord;
import org.gbif.api.vocabulary.ContactType;
import org.gbif.api.vocabulary.DatasetType;
import org.gbif.api.vocabulary.Extension;
import org.gbif.api.vocabulary.GbifRegion;
import org.gbif.api.vocabulary.IdentifierType;
import org.gbif.api.vocabulary.InstallationType;
import org.gbif.api.vocabulary.Kingdom;
import org.gbif.api.vocabulary.MediaType;
import org.gbif.api.vocabulary.NameType;
import org.gbif.api.vocabulary.NameUsageIssue;
import org.gbif.api.vocabulary.OccurrenceIssue;
import org.gbif.api.vocabulary.Origin;
import org.gbif.api.vocabulary.Rank;
import org.gbif.api.vocabulary.TaxonomicStatus;
import org.gbif.api.vocabulary.ThreatStatus;
import org.gbif.api.vocabulary.TypeStatus;

import java.util.Arrays;
import java.util.Collection;
import java.util.ResourceBundle;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import static org.junit.Assert.assertTrue;

/**
 * Checks that all enumerations we use as search parameters have a complete resource bundle entry.
 */
@RunWith(Parameterized.class)
public class ResourceBundleTest {

  Class<? extends Enum<?>> vocab;
  String packageName;

  @Parameterized.Parameters
  public static Collection primeNumbers() {
    return Arrays.asList(new Object[][] {
      {Origin.class, null},
      {GbifRegion.class, "enum.region"},
      {Extension.class, null},
      {Kingdom.class, null},
      {InstallationType.class, null},
      {ContactType.class, null},
      {IdentifierType.class, null},
      {Rank.class, null},
      {ThreatStatus.class, null},
      {DatasetType.class, null},
      {BasisOfRecord.class, null},
      {NameType.class, null},
      {OccurrenceIssue.class, null},
      {NameUsageIssue.class, "enum.usageissue"},
      {TypeStatus.class, null},
      {MediaType.class, null},
      {TaxonomicStatus.class, "enum.taxstatus"}
    });
  }

  public ResourceBundleTest(Class<? extends Enum<?>> vocab, String packageName) {
    this.vocab = vocab;
    this.packageName = packageName;
  }

  @Test
  public void testEnum(){
    ResourceBundle bundle = ResourceBundle.getBundle("resources");
    Enum<?>[] values = vocab.getEnumConstants();
    if (packageName == null) {
      // use default enum package
      packageName = "enum." + vocab.getSimpleName().toLowerCase();
    }
    System.out.println("Assert resource bundle " +packageName+ " contains all " + values.length + " entries for " + vocab.getSimpleName());
    for (Enum<?> en : values) {
      assertTrue("Missing entry for "+ packageName + "." + en.name(), bundle.containsKey(packageName + "." + en.name()));
    }
  }
}
