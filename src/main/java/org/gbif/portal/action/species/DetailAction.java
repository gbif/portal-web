package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.Description;
import org.gbif.api.model.checklistbank.NameUsage;
import org.gbif.api.model.checklistbank.NameUsageComponent;
import org.gbif.api.model.checklistbank.Reference;
import org.gbif.api.model.checklistbank.VernacularName;
import org.gbif.api.model.common.paging.Pageable;
import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.service.checklistbank.DescriptionService;
import org.gbif.api.service.checklistbank.DistributionService;
import org.gbif.api.service.checklistbank.ImageService;
import org.gbif.api.service.checklistbank.ReferenceService;
import org.gbif.api.service.checklistbank.SpeciesProfileService;
import org.gbif.api.service.checklistbank.TypeSpecimenService;
import org.gbif.api.service.checklistbank.VernacularNameService;
import org.gbif.api.service.occurrence.OccurrenceDatasetIndexService;
import org.gbif.api.vocabulary.Language;
import org.gbif.api.vocabulary.Origin;
import org.gbif.api.vocabulary.Rank;
import org.gbif.portal.model.VernacularLocaleComparator;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedMap;
import java.util.UUID;
import javax.annotation.Nullable;
import javax.validation.constraints.NotNull;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Function;
import com.google.common.base.Joiner;
import com.google.common.base.Predicate;
import com.google.common.base.Strings;
import com.google.common.collect.FluentIterable;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Ordering;
import com.google.common.collect.Sets;
import com.google.inject.Inject;

/**
 * Populates the models for the detail page of any taxon.
 * This is done sequentially, on the assumption that the content is well suited to page level caching.
 */
public class DetailAction extends UsageBaseAction {

  private static final long serialVersionUID = -737170459644474553L;

  // only some species have a differing original name (a basionym)
  @Nullable
  private NameUsage basionym;

  private boolean verbatimExists = false;

  @Inject
  private DescriptionService descriptionService;
  @Inject
  private DistributionService distributionService;
  @Inject
  private ImageService imageService;
  @Inject
  private OccurrenceDatasetIndexService occurrenceDatasetService;
  @Inject
  private SpeciesProfileService speciesProfileService;
  @Inject
  private TypeSpecimenService typeSpecimenService;
  @Inject
  private ReferenceService referenceService;
  @Inject
  private VernacularNameService vernacularNameService;

  // Custom sorting of names current locale, then preferring English, then using the name
  private final VernacularLocaleComparator vernacularLocaleComparator = new VernacularLocaleComparator(
    Language.fromIsoCode(getLocale().getISO3Language()));

  // Empty collections are created to safeguard against NPE in freemarker templates
  private final DescriptionToc descriptionToc = new DescriptionToc();
  private final List<String> habitats = Lists.newArrayList();
  private final List<NameUsage> related = Lists.newArrayList();
  private SortedMap<UUID, Integer> occurrenceDatasetCounts = Maps.newTreeMap(); // not final, since replaced
  private final LinkedHashMap<String, List<VernacularName>> vernacularNames = Maps.newLinkedHashMap();
  private boolean nubSourceExists = false;

  // various page sizes used
  private final Pageable page1 = new PagingRequest(0, 1);
  private final Pageable page6 = new PagingRequest(0, 6);
  private final Pageable page10 = new PagingRequest(0, 10);
  private final Pageable page15 = new PagingRequest(0, 15);
  private final Pageable page20 = new PagingRequest(0, 20);
  private final Pageable page50 = new PagingRequest(0, 50);
  private final Pageable page100 = new PagingRequest(0, 100);
  private static final int MAX_COMPONENTS = 10;

  private final static Joiner HABITAT_JOINER = Joiner.on(" ");
  private final static Joiner VERNACULAR_JOINER = Joiner.on("").skipNulls();


  /**
   * Should flag be present, then the habitat named by the flagName is appended to the habitats.
   */
  @VisibleForTesting
  void appendHabitat(Boolean flag, String flagName) {
    if (flag != null) {
      String s = (flag) ?
        getText(flagName) :
        HABITAT_JOINER.join(getText("not"), getText(flagName));
      habitats.add(s);
    }
  }

  /**
   * Populates the model objects sequentially.
   */
  @Override
  public String execute() {
    loadUsage();
    loadUsageDetails();
    populateVernacularNames();
    populateHabitats();

    for (NameUsage u : sublist(related, MAX_COMPONENTS)) {
      loadDataset(u.getDatasetKey());
    }
    for (NameUsageComponent c : usage.getExternalLinks()) {
      loadDataset(c.getDatasetKey());
    }
    for (NameUsageComponent c : usage.getDistributions()) {
      loadDataset(c.getDatasetKey());
    }
    for (NameUsageComponent c : usage.getReferences()) {
      loadDataset(c.getDatasetKey());
    }
    for (NameUsageComponent c : usage.getTypeSpecimens()) {
      loadDataset(c.getDatasetKey());
    }
    for (NameUsageComponent c : usage.getVernacularNames()) {
      loadDataset(c.getDatasetKey());
    }
    for (UUID uuid : sublist(Lists.newArrayList(occurrenceDatasetCounts.keySet()), MAX_COMPONENTS)) {
      loadDataset(uuid);
    }

    return SUCCESS;
  }

  /**
   * @return the usage representing the basionym or null since only some species have a differing original name
   */
  @Nullable
  public NameUsage getBasionym() {
    return basionym;
  }

  @NotNull
  public DescriptionToc getDescriptionToc() {
    return descriptionToc;
  }

  @NotNull
  public List<String> getHabitats() {
    return habitats;
  }

  @NotNull
  public SortedMap<UUID, Integer> getOccurrenceDatasetCounts() {
    return occurrenceDatasetCounts;
  }

  /**
   * Exposed to allow easy access in freemarker.
   */
  public List<Rank> getRankEnum() {
    return Rank.LINNEAN_RANKS;
  }

  @NotNull
  public List<NameUsage> getRelated() {
    return related;
  }

  @NotNull
  public Map<String, String> getResourceBundleProperties() {
    return getResourceBundleProperties("enum.rank.");
  }

  @NotNull
  public Map<String, List<VernacularName>> getVernacularNames() {
    return vernacularNames;
  }

  /**
   * Performs service calls fleshing out the usage model object.
   */
  private void loadUsageDetails() {
    if (usage.getBasionymKey() != null) {
      basionym = usageService.get(usage.getBasionymKey(), getLocale());
    }
    if (usage.getNubKey() != null) {
      List<NameUsage> relatedResponse = usageService.listRelated(usage.getNubKey(), getLocale());
      for (NameUsage u : relatedResponse) {
        // skip oneself
        if (!u.getKey().equals(usage.getKey())) {
          related.add(u);
        }
      }
      occurrenceDatasetCounts = occurrenceDatasetService.occurrenceDatasetsForNubKey(usage.getNubKey());
    }
    usage.setSynonyms(usageService.listSynonyms(id, getLocale(), page6).getResults());
    usage.setVernacularNames(vernacularNameService.listByUsage(id, page100).getResults());
    usage.setDistributions(distributionService.listByUsage(id, page10).getResults());
    usage.setImages(imageService.listByUsage(id, page1).getResults()); // first only
    usage.setTypeSpecimens(typeSpecimenService.listByUsage(id, page10).getResults());
    TypesAction.removeInvalidTypes(usage.getTypeSpecimens());
    usage.setSpeciesProfiles(speciesProfileService.listByUsage(id, page20).getResults());
    for (Description d : descriptionService.listByUsage(id, page50).getResults()) {
      descriptionToc.addDescription(d);
    }

    final Set<String> seenRefs = Sets.newHashSet();
    usage.setReferences(FluentIterable.from(referenceService.listByUsage(id, page15).getResults())
      .filter(new Predicate<Reference>() {
        public boolean apply(@Nullable Reference r) {
          if (r == null) return false;
          // deduplicate references only for nub species
          if (usage.isNub() && seenRefs.contains(r.getCitation())) {
            return false;
          }
          seenRefs.add(r.getCitation());
          return true;
        }
      })
      .toSortedList(Ordering.natural().onResultOf(new Function<Reference, String>() {
        @Override
        public String apply(@Nullable Reference r) {
          return r == null ? null : r.getCitation();
        }
      }))
    );

    if (Origin.SOURCE == usage.getOrigin()) {
      verbatimExists = usageService.getVerbatim(id) != null;
    }

    if (usage.isNub() && usage.getSourceKey() != null) {
      // check if the source record actually exists
      nubSourceExists = usageService.get(usage.getSourceKey(), null) != null;
    }
  }

  /**
   * Populates the habitats first using the boolean flags associated with the usage, and then appending any others.
   */
  private void populateHabitats() {
    appendHabitat(usage.isTerrestrial(), "enum.habitat.terrestrial");
    appendHabitat(usage.isMarine(), "enum.habitat.marine");
    appendHabitat(usage.isFreshwater(), "enum.habitat.freshwater");
    for (String h : usage.getHabitats()) {
      habitats.add(h);
    }
  }

  /**
   * Populates the index of vernacular names.
   * This is a sorted map keyed on the name + language(optional) and order by name and by the rules imposed by
   * {@link #vernacularLocaleComparator}
   */
  @VisibleForTesting
  void populateVernacularNames() {
    List<VernacularName> source = usage.getVernacularNames();
    vernacularNames.clear();
    // total ordering of the names, which is then respected in the sorted map
    for (VernacularName name : Ordering.from(vernacularLocaleComparator).immutableSortedCopy(source)) {

      // skip those that can't be displayed
      if (Strings.isNullOrEmpty(name.getVernacularName())) {
        continue;
      }

      // The names are keyed using name||language where language might be null
      String languageCode = (name.getLanguage() == null) ? null : name.getLanguage().getIso2LetterCode();
      String key = VERNACULAR_JOINER
        .join(
          name.getVernacularName().toLowerCase(),
          "||",
          languageCode);

      // Add to our map index
      List<VernacularName> values = vernacularNames.get(key);
      if (values == null) {
        values = Lists.newArrayList();
        vernacularNames.put(key, values);
      }
      values.add(name);
    }
  }

  public boolean isVerbatimExists() {
    return verbatimExists;
  }

  public boolean isNubSourceExists() {
    return nubSourceExists;
  }
}
