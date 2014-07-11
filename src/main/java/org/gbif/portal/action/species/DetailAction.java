package org.gbif.portal.action.species;

import com.google.common.annotations.VisibleForTesting;
import com.google.common.base.Function;
import com.google.common.base.Joiner;
import com.google.common.base.Predicate;
import com.google.common.base.Predicates;
import com.google.common.collect.*;
import com.google.inject.Inject;
import org.gbif.api.model.checklistbank.*;
import org.gbif.api.model.common.paging.Pageable;
import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.service.checklistbank.*;
import org.gbif.api.service.occurrence.OccurrenceDatasetIndexService;
import org.gbif.api.vocabulary.Language;
import org.gbif.api.vocabulary.MediaType;
import org.gbif.api.vocabulary.Rank;
import org.gbif.portal.model.VernacularLocaleComparator;

import javax.annotation.Nullable;
import javax.validation.constraints.NotNull;
import java.util.*;

/**
 * Populates the models for the detail page of any taxon.
 * This is done sequentially, on the assumption that the content is well suited to page level caching.
 */
public class DetailAction extends UsageBaseAction {

    private static final long serialVersionUID = -737170459644474553L;

    // only some species have a differing original name (a basionym)
    @Nullable
    private NameUsage basionym;

    private TableOfContents toc;

    @Inject
    private DescriptionService descriptionService;
    @Inject
    private DistributionService distributionService;
    @Inject
    private MultimediaService imageService;
    @Inject
    private IdentifierService identifierService;
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

    // Empty collections are created to safeguard against NPE in freemarker templates
    private final List<String> habitats = Lists.newArrayList();
    private final List<NameUsage> related = Lists.newArrayList();
    private SortedMap<UUID, Integer> occurrenceDatasetCounts = Maps.newTreeMap(); // not final, since replaced
    private List<VernacularName> vernacularNames;
    private NameUsageMediaObject primeImage;
    private boolean nubSourceExists = false;

    // various page sizes used
    private final Pageable page1 = new PagingRequest(0, 1);
    private final Pageable page6 = new PagingRequest(0, 6);
    private final Pageable page10 = new PagingRequest(0, 10);
    private final Pageable page15 = new PagingRequest(0, 15);
    private final Pageable page20 = new PagingRequest(0, 20);
    private final Pageable page100 = new PagingRequest(0, 100);
    private static final int MAX_COMPONENTS = 10;

    private final static Joiner HABITAT_JOINER = Joiner.on(" ");

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
        vernacularNames = filterVernacularNames(usage.getVernacularNames(),
            Language.fromIsoCode(getLocale().getISO3Language()));
        populateHabitats();

        for (NameUsage u : sublist(related, MAX_COMPONENTS)) {
            loadDataset(u.getDatasetKey());
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
    public TableOfContents getDescriptionToc() {
        return toc;
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
    public List<VernacularName> getVernacularNames() {
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
        usage.setSynonyms(nonNull(usageService.listSynonyms(id, getLocale(), page6).getResults()));
        usage.setVernacularNames(nonNull(vernacularNameService.listByUsage(id, page100).getResults()));
        usage.setDistributions(nonNull(distributionService.listByUsage(id, page10).getResults()));
        usage.setIdentifiers(nonNull(identifierService.listByUsage(id, page10).getResults()));
        usage.setSpeciesProfiles(nonNull(speciesProfileService.listByUsage(id, page20).getResults()));
        usage.setTypeSpecimens(typeSpecimenService.listByUsage(id, page10).getResults());
        usage.setTypeSpecimens(TypesAction.filterNameTypes(usage));

        toc = descriptionService.getToc(id);
        for (NameUsageMediaObject m : imageService.listByUsage(id, page6).getResults()) {
            if (m.getIdentifier() != null && MediaType.StillImage == m.getType()) {
                primeImage = m;
                break;
            }
        }

        usage.setReferenceList(FluentIterable.from(referenceService.listByUsage(id, page15).getResults())
                .filter(new Predicate<Reference>() {

                    private final Set<String> seenRefs = Sets.newHashSet();

                    public boolean apply(@Nullable Reference r) {
                        if (r == null)
                            return false;
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

        if (usage.isNub() && usage.getSourceTaxonKey() != null) {
            // check if the source record actually exists
            nubSourceExists = usageService.get(usage.getSourceTaxonKey(), null) != null;
        }
    }

    private <T> List<T> nonNull(List<T> x) {
        return FluentIterable.from(x).filter(Predicates.notNull()).toList();
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
     */
    @VisibleForTesting
    List<VernacularName> filterVernacularNames(Collection<VernacularName> vernaculars, @Nullable Language locale) {
        return FluentIterable.from(vernaculars).filter(new Predicate<VernacularName>() {

            private Set<String> seen = Sets.newHashSet();

            @Override
            public boolean apply(@Nullable VernacularName v) {
                StringBuilder sb = new StringBuilder();
                sb.append(v.getLanguage() == null ? Language.ENGLISH.getIso2LetterCode() : v.getLanguage().getIso2LetterCode());
                sb.append(":");
                sb.append(v.getVernacularName());
                final String unique = sb.toString().toLowerCase();
                if (seen.contains(unique)) {
                    return false;
                }
                seen.add(unique);
                return true;
            }
        })
            .toSortedList(new VernacularLocaleComparator(locale));
    }

    /**
     * Adds the vernacular name to the list if it doesn't exist yet in the list.
     */
    private void addVernacularNameIfNotExists(List<VernacularName> vernacularNames, final VernacularName existingName) {
        if (!Iterables.any(vernacularNames, new Predicate<VernacularName>() {

            @Override
            public boolean apply(VernacularName vernacularName) {
                return vernacularName.getVernacularName().equalsIgnoreCase(existingName.getVernacularName())
                    && vernacularName.getSourceTaxonKey().equals(existingName.getSourceTaxonKey());
            }
        })) {
            vernacularNames.add(existingName);
        }
    }

    public boolean isNubSourceExists() {
        return nubSourceExists;
    }

    public NameUsageMediaObject getPrimeImage() {
        return primeImage;
    }

}
