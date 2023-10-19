package com.example.StoreApi.Exceptions;

public class ResourceExists extends  RuntimeException{
    public ResourceExists(String message) {
        super(message);
    }
}
