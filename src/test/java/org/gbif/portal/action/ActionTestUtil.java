package org.gbif.portal.action;

import org.gbif.portal.config.PortalModule;
import org.gbif.portal.config.TestServerMockModule;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class ActionTestUtil {

  public static Injector initTestInjector(){
    return Guice.createInjector(new TestServerMockModule(), new PortalModule());
  }
}
