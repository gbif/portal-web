package org.gbif.portal.action.member;

import org.gbif.api.model.registry.NetworkEntity;
import org.gbif.api.service.registry.DatasetService;
import org.gbif.api.service.registry.InstallationService;
import org.gbif.api.service.registry.NetworkService;
import org.gbif.api.service.registry.NodeService;
import org.gbif.api.service.registry.OrganizationService;
import org.gbif.portal.action.BaseAction;
import org.gbif.portal.exception.NotFoundException;

import java.util.UUID;

import com.google.inject.Inject;

/**
 * Redirects to the typed url for the member or throws NotFoundException.
 */
public class RedirectAction extends BaseAction {

  @Inject
  private OrganizationService organizationService;
  @Inject
  private NodeService nodeService;
  @Inject
  private NetworkService networkService;
  @Inject
  private InstallationService technicalInstallationService;
  @Inject
  private DatasetService datasetService;

  private UUID id;
  private String redirectUrl;

  @Override
  public String execute() {
    if (id != null) {
      NetworkEntity member = organizationService.get(id);
      if (member != null) {
        return redirect(MemberType.PUBLISHER);
      }

      member = nodeService.get(id);
      if (member != null) {
        return redirect(MemberType.NODE);
      }

      member = networkService.get(id);
      if (member != null) {
        return redirect(MemberType.NETWORK);
      }

      member = technicalInstallationService.get(id);
      if (member != null) {
        return redirect(MemberType.INSTALLATION);
      }

      member = datasetService.get(id);
      if (member != null) {
        return redirect(MemberType.DATASET);
      }
    }
    throw new NotFoundException();
  }

  public String getRedirectUrl() {
    return redirectUrl;
  }

  public void setId(String id) {
    try {
      this.id = UUID.fromString(id);
    } catch (Exception e) {
      this.id = null;
    }
  }

  private String redirect(MemberType type) {
    redirectUrl = getBaseUrl() + "/" + type.name().toLowerCase() + "/" + id.toString();
    return SUCCESS;
  }
}
