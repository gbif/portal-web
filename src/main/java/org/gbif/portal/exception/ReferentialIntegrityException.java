package org.gbif.portal.exception;

/**
 * Exception to be thrown if a primary resource can not load all of its related, secondary components.
 * For example if a dataset has just been deleted but a name usage still exists, this exception should be thrown
 * when trying to load the dataset.
 */
public class ReferentialIntegrityException extends RuntimeException {
  private final Class primaryResourceClass;
  private final Object primaryResourceKey;

  private static String buildMessage(Class primaryResourceClass, Object primaryResourceKey) {

    return primaryResourceClass.getSimpleName() + " ["+primaryResourceKey.toString() + "] "
           + "has referential integrity problems.";
  }

  /**
   * @param primaryResourceClass
   * @param primaryResourceKey
   * @param msg additional exception message
   */
  public ReferentialIntegrityException(Class primaryResourceClass, Object primaryResourceKey, String msg) {
    super(buildMessage(primaryResourceClass, primaryResourceKey) + ". " + msg);
    this.primaryResourceClass = primaryResourceClass;
    this.primaryResourceKey = primaryResourceKey;
  }

  /**
   * @param primaryResourceClass
   * @param primaryResourceKey
   */
  public ReferentialIntegrityException(Class primaryResourceClass, Object primaryResourceKey) {
    super(buildMessage(primaryResourceClass, primaryResourceKey));
    this.primaryResourceClass = primaryResourceClass;
    this.primaryResourceKey = primaryResourceKey;
  }


  public Class getPrimaryResourceClass() {
    return primaryResourceClass;
  }

  public Object getPrimaryResourceKey() {
    return primaryResourceKey;
  }
}
