package com.example.StoreApi.controlles;

import com.example.StoreApi.dto.CustomerEntity;
import com.example.StoreApi.models.Customer;
import com.example.StoreApi.services.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("api/v1/customers")
public class CustomerController {
    @Autowired
    CustomerService customerService;


    @GetMapping
    public ResponseEntity<List<Customer>> getCustomer(){
        List<Customer> customers=customerService.getAllCustomers();
        return new ResponseEntity<List<Customer>>(customers, customers.size()==0?HttpStatus.NOT_FOUND:HttpStatus.OK);
    }
    @GetMapping("/{id}")
    public ResponseEntity<Customer> getCustomerById(@PathVariable("id") Long id){
        return new ResponseEntity<Customer>(customerService.getCustomerById(id), HttpStatus.OK);
    }  @PutMapping("/{id}")
    public ResponseEntity<Customer> updateCustomerById(@PathVariable("id") Long id, @RequestBody Customer customer){
        return new ResponseEntity<Customer>(customerService.updateCustomerById(id,customer), HttpStatus.OK);
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCustomerById(@PathVariable("id") Long id){
        customerService.deleteCustomerById(id);
        return new ResponseEntity<>("Customer deleted Successfully", HttpStatus.OK);
    }
}
