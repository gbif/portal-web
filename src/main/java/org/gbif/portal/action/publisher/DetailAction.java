package org.gbif.portal.action.publisher;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.registry.Contact;
import org.gbif.api.model.registry.Dataset;
import org.gbif.api.model.registry.Installation;
import org.gbif.api.model.registry.Node;
import org.gbif.api.model.registry.Organization;
import org.gbif.api.service.checklistbank.DatasetMetricsService;
import org.gbif.api.service.metrics.CubeService;
import org.gbif.api.service.registry.NodeService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.portal.action.member.MemberBaseAction;
import org.gbif.portal.action.member.MemberType;

import java.util.List;

import com.google.common.collect.Lists;
import com.google.inject.Inject;

public class DetailAction extends MemberBaseAction<Organization> {

  @Inject
  private NodeService nodeService;
  private final OrganizationService organizationService;

  private Node node;
  private PagingResponse<Dataset> page;
  private PagingResponse<Installation> installationsPage;
  private long offset = 0;
  private List<Contact> primaryContacts;
  private List<Contact> otherContacts;

  @Inject
  public DetailAction(OrganizationService organizationService, CubeService cubeService,
    DatasetMetricsService datasetMetricsService) {
    super(MemberType.PUBLISHER, organizationService, cubeService, datasetMetricsService, organizationService);
    this.organizationService = organizationService;
  }

  public String datasets() throws Exception {
    super.execute();
    page = organizationService.ownedDatasets(id, new PagingRequest(offset, 25));
    return SUCCESS;
  }

  public String installations() throws Exception {
    super.execute();
    installationsPage = organizationService.installations(id, new PagingRequest(offset, 25));
    return SUCCESS;
  }

  @Override
  public String execute() throws Exception {
    super.execute();
    // load endorsing node
    if (member.getEndorsingNodeKey() != null) {
      node = nodeService.get(member.getEndorsingNodeKey());
    }
    // load first 10 datasets
    page = organizationService.ownedDatasets(id, new PagingRequest(0, 10));
    super.loadCountWrappedDatasets(page);

    // load first 10 hosted installations
    installationsPage = organizationService.installations(id, new PagingRequest(0, 10));
    // separate contacts into 2 lists: primary contacts and other contacts
    loadSeparateContacts();

    return SUCCESS;
  }

  public Node getNode() {
    return node;
  }

  public PagingResponse<Dataset> getPage() {
    return page;
  }

  public PagingResponse<Installation> getInstallationsPage() {
    return installationsPage;
  }

  public void setOffset(long offset) {
    if (offset >= 0) {
      this.offset = offset;
    }
  }

  /**
   * Get a list of publisher's contacts that are designated as primary.
   *
   * @return a list of publisher's contacts that are designated as primary
   */
  public List<Contact> getPrimaryContacts() {
    return primaryContacts;
  }

  /**
   * Get a list of publisher's contacts that are not designated as primary.
   *
   * @return a list of publisher's contacts that are not designated as primary
   */
  public List<Contact> getOtherContacts() {
    return otherContacts;
  }

  /**
   * Separate member's contacts into 2 lists: primary contacts, and others.
   */
  private void loadSeparateContacts() {
    // reinitialize lists
    primaryContacts = Lists.newLinkedList();
    otherContacts = Lists.newLinkedList();
    for (Contact contact : member.getContacts()) {
      if (contact.isPrimary()) {
        primaryContacts.add(contact);
      } else {
        otherContacts.add(contact);
      }
    }
  }
}
