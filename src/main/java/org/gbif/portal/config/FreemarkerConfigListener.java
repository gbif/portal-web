/*
 * Copyright 2011 Global Biodiversity Information Facility (GBIF) Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and limitations under the
 * License.
 */
package org.gbif.portal.config;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import freemarker.log.Logger;

/**
 * Sets up freemarker to use SLF4J for Logging.
 * <p/>
 * SLF4J should be the default for Freemarker 2.4 and up once its released.
 */
public class FreemarkerConfigListener implements ServletContextListener {

  @Override
  public void contextDestroyed(ServletContextEvent sce) {
    // Nothing to destroy for this listener
  }

  @Override
  public void contextInitialized(ServletContextEvent sce) {
    // Configure freemarker to use SLF4J
    // see http://freemarker.sourceforge.net/docs/pgui_misc_logging.html
    try {
      Logger.selectLoggerLibrary(Logger.LIBRARY_SLF4J);
    } catch (ClassNotFoundException e) {
      throw new ConfigurationException(
        "Unable to use SLF4J for Freemarker - check dependencies that freemarker is >2.3.17", e);
    }
  }
}
