package com.example.StoreApi.Exceptions;

public class ResourceNotFound  extends RuntimeException{
    public ResourceNotFound(String message) {
        super(message);
    }
}
