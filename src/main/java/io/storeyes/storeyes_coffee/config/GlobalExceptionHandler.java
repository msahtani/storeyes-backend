package io.storeyes.storeyes_coffee.config;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> handleRuntimeException(RuntimeException e) {
        Map<String, Object> response = new HashMap<>();
        response.put("error", "Bad Request");
        response.put("message", e.getMessage() != null ? e.getMessage() : "An error occurred while processing your request");
        response.put("timestamp", OffsetDateTime.now());
        
        // Determine appropriate HTTP status based on error message
        HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;
        
        // Check for common error patterns that should return 400 Bad Request
        String message = e.getMessage();
        if (message != null) {
            String lowerMessage = message.toLowerCase();
            if (lowerMessage.contains("not found") || 
                lowerMessage.contains("required") ||
                lowerMessage.contains("invalid") ||
                lowerMessage.contains("must be") ||
                lowerMessage.contains("cannot be null") ||
                lowerMessage.contains("format")) {
                status = HttpStatus.BAD_REQUEST;
            }
        }
        
        return ResponseEntity.status(status).body(response);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(MethodArgumentNotValidException e) {
        Map<String, Object> response = new HashMap<>();
        Map<String, String> errors = new HashMap<>();
        
        e.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        
        response.put("error", "Validation Failed");
        response.put("message", "Request validation failed");
        response.put("errors", errors);
        response.put("timestamp", OffsetDateTime.now());
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<Map<String, Object>> handleConstraintViolationException(ConstraintViolationException e) {
        Map<String, Object> response = new HashMap<>();
        
        String violations = e.getConstraintViolations().stream()
                .map(ConstraintViolation::getMessage)
                .collect(Collectors.joining(", "));
        
        response.put("error", "Validation Failed");
        response.put("message", violations);
        response.put("timestamp", OffsetDateTime.now());
        
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }
}
