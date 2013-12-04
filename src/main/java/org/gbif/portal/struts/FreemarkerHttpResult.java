package org.gbif.portal.struts;

import java.io.IOException;
import javax.servlet.http.HttpServletResponse;

import freemarker.template.Template;
import freemarker.template.TemplateModel;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.views.freemarker.FreemarkerResult;

public class FreemarkerHttpResult extends FreemarkerResult {
  private int status;

  public int getStatus() {
    return status;
  }

  public void setStatus(int status) {
    this.status = status;
  }

  @Override
  protected void postTemplateProcess(Template template, TemplateModel data) throws IOException {
    super.postTemplateProcess(template, data);
    if (status >= 100 && status < 600) {
      HttpServletResponse response = ServletActionContext.getResponse();
      response.setStatus(status);
    }
  }

}
