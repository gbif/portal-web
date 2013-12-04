package org.gbif.portal.action.species;

import org.gbif.api.model.checklistbank.TypeSpecimen;
import org.gbif.api.service.checklistbank.TypeSpecimenService;
import org.gbif.api.vocabulary.TypeStatus;

import java.util.Iterator;
import java.util.List;
import java.util.Set;

import com.google.common.base.Strings;
import com.google.common.collect.Sets;
import com.google.inject.Inject;


public class TypesAction extends SeeMoreAction<TypeSpecimen> {
  private static final Set<TypeStatus> TYPE_NAME_STATUS = Sets.newHashSet(TypeStatus.TYPE_GENUS, TypeStatus.TYPE_SPECIES);
  @Inject
  public TypesAction(TypeSpecimenService service) {
    super(service);
  }

  @Override
  public String execute() {
    super.execute();
    TypesAction.removeInvalidTypes(getPage().getResults());
    return SUCCESS;
  }

  /**
   * Iterates over the types in a usage and remove the ones which have bad content - mainly from wikipedia.
   * See http://dev.gbif.org/issues/browse/POR-409
   */
  public static void removeInvalidTypes(List<TypeSpecimen> types){
    Iterator<TypeSpecimen> iter = types.iterator();
    while (iter.hasNext()) {
      TypeSpecimen ts = iter.next();
      if (ts == null || (TYPE_NAME_STATUS.contains(ts.getTypeStatus()) && Strings.isNullOrEmpty(ts.getScientificName()))) {
        iter.remove();
      }
    }
  }
}