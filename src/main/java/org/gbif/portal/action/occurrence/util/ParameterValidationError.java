package org.gbif.portal.action.occurrence.util;

import org.gbif.api.model.common.search.SearchParameter;
import org.gbif.api.model.occurrence.search.OccurrenceSearchParameter;

import javax.annotation.Nullable;
import javax.validation.constraints.NotNull;


/**
 * Represents a validation error in typed parameter ( {@link OccurrenceSearchParameter}, {@link SearchParameter}, etc.).
 * 
 * @param <T> parameter type.
 */
public class ParameterValidationError<T> {

  private T parameter;
  private Throwable error;
  private String urlWithoutError;
  private String value;

  /**
   * Constructor with mandatory values.
   */
  public ParameterValidationError(T parameter, String value,
    String urlWithoutError) {
    this.parameter = parameter;
    this.urlWithoutError = urlWithoutError;
    this.value = value;
  }


  /**
   * Full constructor.
   */
  public ParameterValidationError(T parameter, String value, Throwable error,
    String urlWithoutError) {
    this.parameter = parameter;
    this.error = error;
    this.urlWithoutError = urlWithoutError;
    this.value = value;
  }


  /**
   * Exception that caused the validation error.
   */
  @Nullable
  public Throwable getError() {
    return error;
  }

  /**
   * Parameter that was validated.
   */
  @NotNull
  public T getParameter() {
    return parameter;
  }

  /**
   * HTTP URL without the parameter/value in the query string.
   */
  public String getUrlWithoutError() {
    return urlWithoutError;
  }

  /**
   * Parameter value that caused the validation error.
   */
  public String getValue() {
    return value;
  }

  public void setError(Throwable error) {
    this.error = error;
  }

  public void setParameter(T parameter) {
    this.parameter = parameter;
  }


  public void setUrlWithoutError(String urlWithoutError) {
    this.urlWithoutError = urlWithoutError;
  }


  public void setValue(String value) {
    this.value = value;
  }

}
