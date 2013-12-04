package org.gbif.portal.struts;

import java.io.Writer;

import com.opensymphony.xwork2.inject.Inject;
import org.apache.struts2.components.Form;
import org.apache.struts2.components.ServletUrlRenderer;
import org.apache.struts2.components.UrlProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Custom struts URL renderer that takes a global configuration to turn on/off the addition of the servlet context
 * to a URL. This is needed for GBIF to run the portal with a /portal context, but expose it publicly behind
 * varnish in the root context.
 */
public class ConfigurableServletUrlRenderer extends ServletUrlRenderer {
  private static final Logger LOG = LoggerFactory.getLogger(ConfigurableServletUrlRenderer.class);

  private final boolean addContext;

  @Inject("struts.url.includeContext")
  public ConfigurableServletUrlRenderer(String addContext) {
    LOG.info("Configure struts tags to include the servlet context: " + addContext);
    this.addContext = Boolean.parseBoolean(addContext);
  }

  @Override
  public void renderUrl(Writer writer, UrlProvider urlComponent) {
    urlComponent.setIncludeContext(addContext);
    super.renderUrl(writer, urlComponent);
  }

  @Override
  public void renderFormUrl(Form formComponent) {
    formComponent.setIncludeContext(addContext);
    super.renderFormUrl(formComponent);
  }
}
