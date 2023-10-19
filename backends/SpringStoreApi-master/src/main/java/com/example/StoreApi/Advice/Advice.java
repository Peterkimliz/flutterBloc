package com.example.StoreApi.Advice;

import com.example.StoreApi.Exceptions.ExceptionObject;
import com.example.StoreApi.Exceptions.ResourceExists;
import com.example.StoreApi.Exceptions.ResourceNotFound;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;


@ControllerAdvice
public class Advice {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ExceptionObject> inputsValidation(MethodArgumentNotValidException ex){
        ExceptionObject exceptionObject=new ExceptionObject();
        ex.getBindingResult().getFieldErrors().forEach(e->{
            exceptionObject.setMessage(e.getDefaultMessage());
        });
       return new ResponseEntity<ExceptionObject>(exceptionObject, HttpStatus.CONFLICT);
    }
    @ExceptionHandler(ResourceExists.class)
    public ResponseEntity<ExceptionObject> resourceFoundException(ResourceExists e){
        ExceptionObject exceptionObject=new ExceptionObject();
        exceptionObject.setMessage(e.getMessage());
       return new ResponseEntity<ExceptionObject>(exceptionObject, HttpStatus.CONFLICT);
    }

    @ExceptionHandler(ResourceNotFound.class)
    public ResponseEntity<ExceptionObject> resourceNotFound(ResourceNotFound e){
        ExceptionObject exceptionObject=new ExceptionObject();
        exceptionObject.setMessage(e.getMessage());
       return new ResponseEntity<ExceptionObject>(exceptionObject, HttpStatus.NOT_FOUND);
    }

}
