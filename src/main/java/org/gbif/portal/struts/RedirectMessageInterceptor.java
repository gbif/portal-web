package org.gbif.portal.struts;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.Result;
import com.opensymphony.xwork2.ValidationAware;
import com.opensymphony.xwork2.interceptor.MethodFilterInterceptor;
import org.apache.struts2.dispatcher.ServletRedirectResult;

/**
 * An Interceptor to preserve an actions ValidationAware messages across a
 * redirect result.
 * It makes the assumption that you always want to preserve messages across a
 * redirect and restore them to the next action if they exist.
 * The way this works is it looks at the result type after a action has executed
 * and if the result was a redirect (ServletRedirectResult) or a redirectAction
 * (ServletActionRedirectResult) and there were any errors, messages, or
 * fieldErrors they are stored in the session. Before the next action executes
 * it will check if there are any messages stored in the session and add them to
 * the next action.
 *
 * @see <a href="http://glindholm.wordpress.com/2008/07/02/preserving-messages-across-a-redirect-in-struts-2/">Preserving
 *      Messages Across a Redirect in Struts
 *      2</a>
 */
public class RedirectMessageInterceptor extends MethodFilterInterceptor {

  private static final long serialVersionUID = -1847557437429753540L;

  public static final String FIELD_ERRORS_KEY = "RedirectMessageInterceptor_FieldErrors";
  public static final String ACTION_ERRORS_KEY = "RedirectMessageInterceptor_ActionErrors";
  public static final String ACTION_MESSAGES_KEY = "RedirectMessageInterceptor_ActionMessages";

  @Override
  public String doIntercept(final ActionInvocation invocation) throws Exception {
    final Object action = invocation.getAction();
    if (action instanceof ValidationAware) {
      before(invocation, (ValidationAware) action);
    }

    final String result = invocation.invoke();

    if (action instanceof ValidationAware) {
      after(invocation, (ValidationAware) action);
    }
    return result;
  }

  /**
   * Retrieve the errors and messages from the session and add them to the
   * action.
   */
  protected void before(final ActionInvocation invocation, final ValidationAware validationAware) throws Exception {
    @SuppressWarnings("unchecked")
    final Map<String, ?> session = invocation.getInvocationContext().getSession();

    @SuppressWarnings("unchecked")
    final Collection<String> actionErrors = (Collection) session.remove(ACTION_ERRORS_KEY);
    if (actionErrors != null && !actionErrors.isEmpty()) {
      for (final String error : actionErrors) {
        validationAware.addActionError(error);
      }
    }

    @SuppressWarnings("unchecked")
    final Collection<String> actionMessages = (Collection) session.remove(ACTION_MESSAGES_KEY);
    if (actionMessages != null && !actionMessages.isEmpty()) {
      for (final String message : actionMessages) {
        validationAware.addActionMessage(message);
      }
    }

    @SuppressWarnings("unchecked")
    final Map<String, List<String>> fieldErrors = (Map) session.remove(FIELD_ERRORS_KEY);
    if (fieldErrors != null && !fieldErrors.isEmpty()) {
      for (final Map.Entry<String, List<String>> fieldError : fieldErrors.entrySet()) {
        for (final String message : fieldError.getValue()) {
          validationAware.addFieldError(fieldError.getKey(), message);
        }
      }
    }
  }

  /**
   * If the result is a redirect then store error and messages in the session.
   */
  protected void after(final ActionInvocation invocation, final ValidationAware validationAware) throws Exception {
    final Result result = invocation.getResult();

    if (result != null && result instanceof ServletRedirectResult) {
      final Map<String, Object> session = invocation.getInvocationContext().getSession();

      final Collection<String> actionErrors = validationAware.getActionErrors();
      if (actionErrors != null && !actionErrors.isEmpty()) {
        session.put(ACTION_ERRORS_KEY, actionErrors);
      }

      final Collection<String> actionMessages = validationAware.getActionMessages();
      if (actionMessages != null && !actionMessages.isEmpty()) {
        session.put(ACTION_MESSAGES_KEY, actionMessages);
      }

      final Map<String, List<String>> fieldErrors = validationAware.getFieldErrors();
      if (fieldErrors != null && !fieldErrors.isEmpty()) {
        session.put(FIELD_ERRORS_KEY, fieldErrors);
      }
    }
  }
}
