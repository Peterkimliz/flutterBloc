package com.ips.ipsManager.Advice;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.ips.ipsManager.Exceptions.ExceptionObject;
import com.ips.ipsManager.Exceptions.FoundException;
import com.ips.ipsManager.Exceptions.JwtExceptionObject;
import com.ips.ipsManager.Exceptions.NotFoundException;

import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.SignatureException;

@RestControllerAdvice
public class ExceptioAdvice {

  @ExceptionHandler(MethodArgumentNotValidException.class)  
  public ResponseEntity<ExceptionObject> inputsError(MethodArgumentNotValidException exception){
    ExceptionObject exceptionObject=new ExceptionObject();

    List<ObjectError>errors= exception.getAllErrors();
    for (ObjectError objectError : errors) {
        exceptionObject.setMessage(objectError.getDefaultMessage());
        
    }

    return new ResponseEntity<ExceptionObject>(exceptionObject,HttpStatus.BAD_REQUEST);
  }


  @ExceptionHandler(FoundException.class)  
  public ResponseEntity<ExceptionObject> foundException(FoundException exception){
    ExceptionObject exceptionObject=new ExceptionObject();
    exceptionObject.setMessage(exception.getMessage());
    return new ResponseEntity<ExceptionObject>(exceptionObject,HttpStatus.CONFLICT);
  }
  @ExceptionHandler(NotFoundException.class)  
  public ResponseEntity<ExceptionObject> notFoundException(NotFoundException exception){
    ExceptionObject exceptionObject=new ExceptionObject();
    exceptionObject.setMessage(exception.getMessage());
    return new ResponseEntity<ExceptionObject>(exceptionObject,HttpStatus.NOT_FOUND);
  }


  @ExceptionHandler(ExpiredJwtException.class)  
  public ResponseEntity<JwtExceptionObject> expiredToken(ExpiredJwtException exception){
    JwtExceptionObject exceptionObject=new JwtExceptionObject();
    exceptionObject.setMessage(exception.getMessage());
    exceptionObject.setReason("jwt Already expired");
    return new ResponseEntity<JwtExceptionObject>(exceptionObject,HttpStatus.FORBIDDEN);
  }
  @ExceptionHandler(SignatureException.class)  
  public ResponseEntity<JwtExceptionObject> inValidToken(SignatureException exception){
    JwtExceptionObject exceptionObject=new JwtExceptionObject();
    exceptionObject.setMessage(exception.getMessage());
    exceptionObject.setReason("Invalid token");
    return new ResponseEntity<JwtExceptionObject>(exceptionObject,HttpStatus.FORBIDDEN);
  }
  @ExceptionHandler(MalformedJwtException.class)  
  public ResponseEntity<JwtExceptionObject> malformedJwtException(MalformedJwtException exception){
    JwtExceptionObject exceptionObject=new JwtExceptionObject();
    exceptionObject.setMessage(exception.getMessage());
    exceptionObject.setReason("Invalid token");
    return new ResponseEntity<JwtExceptionObject>(exceptionObject,HttpStatus.FORBIDDEN);
  }

    
}
