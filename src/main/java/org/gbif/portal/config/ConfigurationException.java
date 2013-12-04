package org.gbif.portal.config;

/**
 * Indicates that the application configuration is incorrect.
 *
 * @author timrobertson
 */
public class ConfigurationException extends RuntimeException {

  public ConfigurationException(String message, Throwable cause) {
    super(message, cause);
  }

  public ConfigurationException(String message) {
    super(message);
  }
}
