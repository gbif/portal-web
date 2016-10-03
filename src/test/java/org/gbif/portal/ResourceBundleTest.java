package org.gbif.portal;

import org.gbif.api.model.checklistbank.search.NameUsageSearchParameter;
import org.gbif.api.model.occurrence.Download;
import org.gbif.api.model.occurrence.DownloadFormat;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;
import org.gbif.api.model.registry.search.DatasetSearchParameter;
import org.gbif.api.vocabulary.BasisOfRecord;
import org.gbif.api.vocabulary.ContactType;
import org.gbif.api.vocabulary.Continent;
import org.gbif.api.vocabulary.DatasetType;
import org.gbif.api.vocabulary.EndpointType;
import org.gbif.api.vocabulary.EstablishmentMeans;
import org.gbif.api.vocabulary.Extension;
import org.gbif.api.vocabulary.GbifRegion;
import org.gbif.api.vocabulary.Habitat;
import org.gbif.api.vocabulary.IdentifierType;
import org.gbif.api.vocabulary.InstallationType;
import org.gbif.api.vocabulary.Kingdom;
import org.gbif.api.vocabulary.License;
import org.gbif.api.vocabulary.MediaType;
import org.gbif.api.vocabulary.NameType;
import org.gbif.api.vocabulary.NameUsageIssue;
import org.gbif.api.vocabulary.NodeType;
import org.gbif.api.vocabulary.OccurrenceIssue;
import org.gbif.api.vocabulary.OccurrenceStatus;
import org.gbif.api.vocabulary.Origin;
import org.gbif.api.vocabulary.PreservationMethodType;
import org.gbif.api.vocabulary.Rank;
import org.gbif.api.vocabulary.TaxonomicStatus;
import org.gbif.api.vocabulary.ThreatStatus;
import org.gbif.api.vocabulary.TypeStatus;
import org.gbif.portal.action.member.MemberType;

import java.util.Arrays;
import java.util.Collection;
import java.util.ResourceBundle;
import java.util.Set;

import com.google.common.collect.Sets;
import org.junit.Ignore;
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
  private static Set<String> entries = Sets.newHashSet();

  @Parameterized.Parameters
  public static Collection primeNumbers() {
    return Arrays.asList(new Object[][]{
        {NameType.class, null},
        {OccurrenceStatus.class, null},
        {EstablishmentMeans.class, null},
        {IdentifierType.class, null},
        {DatasetType.class, null},
        {PreservationMethodType.class, null},
        {Rank.class, null},
        {ThreatStatus.class, null},
        {OccurrenceIssue.class, null},
        {NameUsageIssue.class, "enum.usageissue"},
        {ContactType.class, null},
        {MemberType.class, null},
        {InstallationType.class, null},
        {NodeType.class, null},
        {GbifRegion.class, "enum.region"},
        {Continent.class, null},
        {EndpointType.class, null},
        {Kingdom.class, null},
        {Extension.class, null},
        {MediaType.class, null},
        {BasisOfRecord.class, null},
        {Origin.class, null},
        {Habitat.class, null},
        {TypeStatus.class, null},
        {TaxonomicStatus.class, "enum.taxstatus"},

        {License.class, null},
        {DownloadFormat.class, null},
        {Download.Status.class, "enum.downloadstatus"},

        {DatasetSearchParameter.class, "search.facet"},
        {OccurrenceSearchParameter.class, "search.facet"},
        {NameUsageSearchParameter.class, "search.facet"},
    });
  }

  public ResourceBundleTest(Class<? extends Enum<?>> vocab, String packageName) {
    this.vocab = vocab;
    this.packageName = packageName;
  }

  @Test
  public void testEnum() {
    ResourceBundle bundle = ResourceBundle.getBundle("resources");
    Enum<?>[] values = vocab.getEnumConstants();
    if (packageName == null) {
      // use default enum package
      packageName = "enum." + vocab.getSimpleName().toLowerCase();
    }
    System.out.println("Assert resource bundle " + packageName + " contains all " + values.length + " entries for " + vocab.getSimpleName());
    for (Enum<?> en : values) {
      assertTrue("Missing entry for " + packageName + "." + en.name(), bundle.containsKey(packageName + "." + en.name()));
    }
  }

  @Test
  @Ignore("Manual method to produce a resource bundle entry list for a given enumeration")
  public void listEnums() {
    ResourceBundle bundle = ResourceBundle.getBundle("resources");
    System.out.println("\n\n# " + vocab.getSimpleName());
    Enum<?>[] values = vocab.getEnumConstants();
    if (packageName == null) {
      // use default enum package
      packageName = "enum." + vocab.getSimpleName().toLowerCase();
    }
    for (Enum<?> en : values) {
      String entry = packageName + "." + en.name();
      String label = bundle.containsKey(entry) ? bundle.getString(entry) : en.name().toLowerCase().replaceAll("_", " ");
      if (entries.contains(entry)) {
        System.out.println("# " + entry);
      } else {
        System.out.println(entry + "=" + label);
        entries.add(entry);
      }
    }
  }
}
