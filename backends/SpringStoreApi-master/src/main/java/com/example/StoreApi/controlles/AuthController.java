package com.example.StoreApi.controlles;

import com.example.StoreApi.dto.CustomerEntity;
import com.example.StoreApi.models.Customer;
import com.example.StoreApi.services.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    @Autowired
    CustomerService customerService;
    @PostMapping
    public ResponseEntity<Customer> createCustomer(@RequestBody @Validated CustomerEntity customerEntity){
        return new ResponseEntity<Customer>(customerService.createcustomer(customerEntity), HttpStatus.CREATED);
    }
}
