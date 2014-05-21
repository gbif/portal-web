package org.gbif.portal.action.occurrence;

import org.gbif.api.model.common.MediaObject;
import org.gbif.api.model.occurrence.VerbatimOccurrence;
import org.gbif.api.model.registry.Organization;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.api.vocabulary.Extension;
import org.gbif.api.vocabulary.MediaType;
import org.gbif.dwc.terms.DcTerm;
import org.gbif.dwc.terms.DwcTerm;
import org.gbif.dwc.terms.GbifTerm;
import org.gbif.dwc.terms.Term;
import org.gbif.dwc.terms.TermFactory;
import org.gbif.portal.action.occurrence.util.MockOccurrenceFactory;

import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

import com.google.common.collect.Lists;

import com.google.common.base.Throwables;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import org.codehaus.jackson.map.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.gbif.api.model.Constants.NUB_DATASET_KEY;

public class DetailAction extends OccurrenceBaseAction {

  private static final Logger LOG = LoggerFactory.getLogger(DetailAction.class);
  private static final TermFactory TERM_FACTORY = TermFactory.instance();

  @Inject
  private OrganizationService organizationService;

  private Organization publisher;
  private VerbatimOccurrence v;
  private Map<String, Map<String, String>> verbatim;
  private Map<Extension, List<Map<Term, String>>> verbatimExtensions;

  private boolean fragmentExists = false;
  private static final ObjectMapper MAPPER = new ObjectMapper();


  @Override
  public String execute() {
    // load occurrence, including all verbatim terms (organized by group)
    verbatim();
    // load publisher
    if (dataset.getOwningOrganizationKey() != null) {
      publisher = organizationService.get(dataset.getOwningOrganizationKey());
    }

    return SUCCESS;
  }

  public List<MediaObject> getVideos() {
    return filterFor(occ.getMedia(), MediaType.MovingImage);
  }

  /**
   * Inspects the media to determine if the image gallery can show.
   */
  public boolean hasImages() {
    for (MediaObject m : occ.getMedia()) {
      if (MediaType.StillImage == m.getType() && m.getIdentifier() != null) {
        return true;
      }
    }
    return false;
  }

    public List<MediaObject> getAudio() {
    return filterFor(occ.getMedia(), MediaType.Sound);
  }

  public List<MediaObject> getImages() {
    return filterFor(occ.getMedia(), MediaType.StillImage);
  }

  private List<MediaObject> filterFor(List<MediaObject> media, MediaType type) {
    List<MediaObject> filtered = Lists.newArrayList();
    for (MediaObject m : media) {
      if (type == m.getType()) {
        filtered.add(m);
      }
    }
    return filtered;
  }

  public String getMedia() {
    try {
      return MAPPER.writeValueAsString(occ.getMedia());
    } catch (Exception e) {
      // we are hosed
      throw Throwables.propagate(e);
    }
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

  /**
   * Retrieve verbatim value for a Term.
   * Accepts any term the TermFactory can deal with.
   *
   * @param termName simple or full name of any Term
   * @return verbatim value for core Term, or null if it doesn't exist
   */
  public String verbatimValue(String termName) {
    Term term = TERM_FACTORY.findTerm(termName);
    return term == null || v == null ? null : v.getVerbatimField(term);
  }

  /**
   * Retrieve interpreted value for a Term.
   * Accepts any term the TermFactory can deal with.
   *
   * @param termName simple or full name of any Term
   * @return interpreted or unaltered verbatim value for core Term, or null if it doesn't exist
   */
  public String termValue(String termName) {
    Term term = TERM_FACTORY.findTerm(termName);
    return term == null || occ == null ? null : occ.getVerbatimField(term);
  }

  public String verbatim() {
    LOG.debug("Loading raw details for occurrence id [{}]", id);

    // load occurrence
    loadDetail();

    // prepare verbatim map
    verbatim = Maps.newLinkedHashMap();
    try {
      fragmentExists = occurrenceService.getFragment(id) != null;
      // check if the mock occurrence should be loaded
      // TODO: revert change when moving to production
      v = id == -1000000000 ? MockOccurrenceFactory.getMockOccurrence() : occurrenceService.getVerbatim(id);

      // copy extensions data
      verbatimExtensions = v.getExtensions();

      // build core fields with custom ordering/grouping
      for (String group : DwcTerm.GROUPS) {
        for (DwcTerm t : DwcTerm.listByGroup(group)) {
          if (v.getVerbatimFields().containsKey(t)) {
            if (!verbatim.containsKey(group)) {
              verbatim.put(group, new TreeMap<String, String>());
            }
            verbatim.get(group).put(t.simpleName(), v.getVerbatimFields().get(t));
          }
        }
      }
      // now add all non dwc terms
      Map<String, String> gbif = new TreeMap<String, String>();
      Map<String, String> dc = new TreeMap<String, String>();
      Map<String, String> others = new TreeMap<String, String>();
      for (Map.Entry<Term, String> field : v.getVerbatimFields().entrySet()) {
        Term t = field.getKey();
        if (t instanceof DwcTerm) {
          // skip, its in the map already
        } else {
          if (t instanceof GbifTerm) {
            gbif.put(t.simpleName(), field.getValue());
          } else if (t instanceof DcTerm) {
            dc.put(t.simpleName(), field.getValue());
          } else {
            others.put(t.simpleName(), field.getValue());
          }
        }
      }
      if (!gbif.isEmpty()) {
        verbatim.put("GBIF", gbif);
      }

      // All DC terms get added to Record-level group
      if (!dc.isEmpty()) {
        // ensure Record-level group exists in verbatim
        if (!verbatim.containsKey(DwcTerm.GROUP_RECORD)) {
          verbatim.put(DwcTerm.GROUP_RECORD, new TreeMap<String, String>());
        }
        verbatim.get(DwcTerm.GROUP_RECORD).putAll(dc);
      }

      if (!others.isEmpty()) {
        verbatim.put("Other", others);
      }

    } catch (Exception e) {
      LOG.error("Can't load verbatim data for occurrence {}: {}", id, e);
    }

    return SUCCESS;
  }

  public Map<Extension, List<Map<Term, String>>> getVerbatimExtensions() {
    return verbatimExtensions;
  }
}
