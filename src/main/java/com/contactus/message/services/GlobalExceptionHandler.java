/*
 * package com.contactus.message.services;
 * 
 * import java.util.List; import java.util.stream.Collectors;
 * 
 * import org.springframework.http.HttpStatus; import
 * org.springframework.http.ResponseEntity; import
 * org.springframework.web.bind.MethodArgumentNotValidException; import
 * org.springframework.web.bind.annotation.ControllerAdvice; import
 * org.springframework.web.bind.annotation.ExceptionHandler; import
 * org.springframework.web.bind.annotation.ResponseStatus;
 * 
 * @ControllerAdvice public class GlobalExceptionHandler {
 * 
 * @ExceptionHandler(MethodArgumentNotValidException.class)
 * 
 * @ResponseStatus(HttpStatus.BAD_REQUEST) public ResponseEntity<Object>
 * handleValidationErrors(MethodArgumentNotValidException ex) { List<String>
 * errorMessages = ex.getBindingResult().getFieldErrors() .stream() .map(error
 * -> error.getField() + " " + error.getDefaultMessage())
 * .collect(Collectors.toList()); return
 * ResponseEntity.badRequest().body(errorMessages); } }
 */