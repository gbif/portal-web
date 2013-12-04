package org.gbif.portal.action.occurrence;

import org.gbif.portal.exception.NotFoundException;
import org.gbif.api.service.occurrence.OccurrenceService;
import org.gbif.api.service.occurrence.VerbatimOccurrenceService;
import org.gbif.portal.action.BaseAction;

import java.io.IOException;
import java.io.InputStream;

import com.google.inject.Inject;
import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FragmentAction extends BaseAction {

  private static final Logger LOG = LoggerFactory.getLogger(FragmentAction.class);
  @Inject
  protected OccurrenceService occurrenceService;
  @Inject
  private VerbatimOccurrenceService verbatimService;

  private InputStream stream;
  private Integer id;

  @Override
  public String execute() throws IOException {
    if (id == null) {
      throw new NotFoundException("No occurrence id given");
    }

    String fragment = occurrenceService.getFragment(id);
    if (fragment == null) {
      throw new NotFoundException("No occurrence fragment found with id " + id);
    }

    stream = IOUtils.toInputStream(fragment, "UTF-8");
    return SUCCESS;
  }

  public Integer getId() {
    return id;
  }

  public void setId(Integer id) {
    this.id = id;
  }

  public InputStream getStream() {
    return stream;
  }
}
