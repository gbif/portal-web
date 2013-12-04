package org.gbif.portal.action.occurrence;

import org.gbif.api.model.occurrence.VerbatimOccurrence;
import org.gbif.api.model.registry.Organization;
import org.gbif.api.service.occurrence.VerbatimOccurrenceService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.dwc.terms.DwcTerm;

import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

import com.google.common.collect.Maps;
import com.google.inject.Inject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.gbif.api.model.Constants.NUB_DATASET_KEY;

public class DetailAction extends OccurrenceBaseAction {

  private static final Logger LOG = LoggerFactory.getLogger(DetailAction.class);

  @Inject
  private OrganizationService organizationService;
  @Inject
  private VerbatimOccurrenceService verbatimService;

  private Organization publisher;
  private Map<String, Map<String, String>> verbatim;
  private boolean fragmentExists = false;


  @Override
  public String execute() {
    loadDetail();
    // load publisher
    if (dataset.getOwningOrganizationKey() != null) {
      publisher = organizationService.get(dataset.getOwningOrganizationKey());
    }

    return SUCCESS;
  }

  /**
   * Exposed to allow easy access in freemarker.
   */
  public UUID getNubDatasetKey() {
    return NUB_DATASET_KEY;
  }

  public Organization getPublisher() {
    return publisher;
  }

  public Map<String, Map<String, String>> getVerbatim() {
    return verbatim;
  }

  public boolean isFragmentExists() {
    return fragmentExists;
  }

  public String verbatim() {
    LOG.debug("Loading raw details for occurrence id [{}]", id);

    loadDetail();

    // prepare verbatim map
    verbatim = Maps.newLinkedHashMap();
    try {
      fragmentExists = occurrenceService.getFragment(id) != null;
      VerbatimOccurrence v = verbatimService.getVerbatim(id);
      for (String group : DwcTerm.GROUPS) {
        for (DwcTerm t : DwcTerm.listByGroup(group)) {
          if (v.getFields().containsKey(t.simpleName())) {
            if (!verbatim.containsKey(group)) {
              verbatim.put(group, new TreeMap<String, String>());
            }
            verbatim.get(group).put(t.simpleName(), v.getFields().get(t.simpleName()));
          }
        }
      }
    } catch (Exception e) {
      LOG.error("Can't load verbatim data for occurrence {}: {}", id, e);
    }

    return SUCCESS;
  }
}
