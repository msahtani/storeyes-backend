package io.storeyes.storeyes_coffee.feedback.exceptions;

/**
 * Thrown when trying to hard-delete a {@code FeedbackQuestion} that already has
 * customer answers recorded against it. Deleting it would either violate the
 * feedback_answers FK constraint or, if cascaded, silently destroy historical
 * per-question stats. Callers should deactivate the question instead.
 */
public class QuestionInUseException extends RuntimeException {

    public QuestionInUseException(String message) {
        super(message);
    }
}
