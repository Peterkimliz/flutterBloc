package com.example.StoreApi.services;

import com.example.StoreApi.Exceptions.ResourceExists;
import com.example.StoreApi.Exceptions.ResourceNotFound;
import com.example.StoreApi.dto.CustomerEntity;
import com.example.StoreApi.models.Customer;
import com.example.StoreApi.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
public class CustomerService {
    @Autowired
    private CustomerRepository customerRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;
    public Customer createcustomer(CustomerEntity customerEntity){
        Customer customer =new Customer();
        Optional<Customer> foundCustomer=customerRepository.findByEmail(customerEntity.getEmail());
        if(foundCustomer.isPresent()){
            throw new ResourceExists("customer with email address already exists");
        }
        customer.setEmail(customerEntity.getEmail());
        customer.setUsername(customerEntity.getUsername());
        customer.setPhone(customerEntity.getPhone());
        customer.setPassword(passwordEncoder.encode(customerEntity.getPassword()));
        customer.setCreatedAt(new Date(System.currentTimeMillis()));
        customer.setUpdatedAt(new Date(System.currentTimeMillis()));
       return customerRepository.save(customer);
    }

    public List<Customer> getAllCustomers(){
        List<Customer> customers=customerRepository.findAll();
        if (customers.size()==0){
            return new ArrayList<>();
        }
        return customers;
    }
    public Customer getCustomerById(Long id){
        Optional<Customer> customer=customerRepository.findById(id);
        if (customer.isEmpty()){
             throw new ResourceNotFound("Customer Not Found");
        }
        return customer.get();
    }
    public Customer updateCustomerById(Long id,Customer customer){
        Optional<Customer> foundCustomer=customerRepository.findById(id);
        if (foundCustomer.isEmpty()){
             throw new ResourceNotFound("Customer Not Found");
        }else{
            Customer saveUpdatedCustomer=foundCustomer.get();
            saveUpdatedCustomer.setUpdatedAt(new Date(System.currentTimeMillis()));
            saveUpdatedCustomer.setUsername(customer.getUsername()==null?saveUpdatedCustomer.getUsername():customer.getUsername());
            saveUpdatedCustomer.setPhone(customer.getPhone()==null?saveUpdatedCustomer.getPhone():customer.getPhone());
            customerRepository.save(saveUpdatedCustomer);
            return saveUpdatedCustomer;
        }

    }

    public void deleteCustomerById(Long id){
        Optional<Customer> customer=customerRepository.findById(id);
        if (customer.isEmpty()){
             throw new ResourceNotFound("Customer Not Found");
        }
       customerRepository.deleteById(id);
    }

}
