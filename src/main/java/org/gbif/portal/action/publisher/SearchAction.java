package org.gbif.portal.action.publisher;

import org.gbif.api.model.common.paging.PagingRequest;
import org.gbif.api.model.common.paging.PagingResponse;
import org.gbif.api.model.registry.Node;
import org.gbif.api.model.registry.Organization;
import org.gbif.api.service.registry.NodeService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.portal.action.BaseAction;

import java.util.Map;
import java.util.UUID;

import com.google.common.collect.Maps;
import com.google.inject.Inject;

/**
 * This is a simple paging search action that uses registry (v2+) web services to support basic organization listings. 
 */
@SuppressWarnings("serial")
public class SearchAction extends BaseAction {

  private static final int PAGE_SIZE = 20;
  
  private final OrganizationService organizationService;
  private final NodeService nodeService;
  
  private long offset = 0;
  private String q;
  private PagingResponse<Organization> page;
  // required to show the titles
  private Map<UUID,Node> nodeIndex = Maps.newHashMap();

  @Inject
  public SearchAction(OrganizationService organizationService, NodeService nodeService) {
    this.organizationService = organizationService;
    this.nodeService = nodeService;
  }

  @Override
  public String execute() throws Exception {
    // TODO: Support ordering
    // http://dev.gbif.org/issues/browse/REG-415
    page = organizationService.search(q, new PagingRequest(offset, PAGE_SIZE));
    
    for (Organization o : page.getResults()) {
      if (!nodeIndex.containsKey(o.getEndorsingNodeKey())) {
        nodeIndex.put(o.getEndorsingNodeKey(), nodeService.get(o.getEndorsingNodeKey()));  
      }
    }
    
    LOG.info("Searching for publisher with query[{}] produced {} results", q, page.getCount());
    return SUCCESS;
  }

  public PagingResponse<Organization> getPage() {
    return page;
  }

  // safe setting to 0 or more
  public void setOffset(long offset) {
    this.offset = offset > 0 ? offset : 0; 
  }
  
  public String getQ() {
    return q;
  }
  
  public void setQ(String q) {
    this.q = q;
  }
  
  public Map<UUID, Node> getNodeIndex() {
    return nodeIndex;
  }
}
