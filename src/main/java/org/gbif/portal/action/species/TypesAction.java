package org.gbif.portal.action.species;

import com.google.common.base.Predicate;
import com.google.common.base.Strings;
import com.google.common.collect.FluentIterable;
import com.google.common.collect.Sets;
import com.google.inject.Inject;
import org.gbif.api.model.checklistbank.NameUsageContainer;
import org.gbif.api.model.checklistbank.TypeSpecimen;
import org.gbif.api.service.checklistbank.TypeSpecimenService;
import org.gbif.api.vocabulary.TypeStatus;

import java.util.List;
import java.util.Set;


public class TypesAction extends SeeMoreAction<TypeSpecimen> {
    private static final Set<TypeStatus> TYPE_NAME_STATUS = Sets.newHashSet(TypeStatus.TYPE_GENUS, TypeStatus.TYPE_SPECIES);

    @Inject
    public TypesAction(TypeSpecimenService service) {
        super(service);
    }

    @Override
    public String execute() {
        super.execute();
        usage.setTypeSpecimens(filterNameTypes(usage));
        return SUCCESS;
    }


    /**
     * Iterates over the types in a usage and remove the ones which have bad content - mainly from wikipedia.
     * See http://dev.gbif.org/issues/browse/POR-409
     */
    public static List<TypeSpecimen> filterNameTypes(final NameUsageContainer use) {
        return FluentIterable
            .from(use.getTypeSpecimens())
            .filter(new Predicate<TypeSpecimen>() {
                @Override
                public boolean apply(TypeSpecimen ts) {
                    return ts != null
                        && TYPE_NAME_STATUS.contains(ts.getTypeStatus())
                        && !Strings.isNullOrEmpty(ts.getScientificName())
                        && (use.getRank() == null || !use.getRank().isSpeciesOrBelow());
                }
            })
            .toList();
    }
}