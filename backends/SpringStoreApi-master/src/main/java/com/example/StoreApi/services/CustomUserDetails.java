package com.example.StoreApi.services;

import com.example.StoreApi.Exceptions.ResourceNotFound;
import com.example.StoreApi.models.Customer;
import com.example.StoreApi.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Optional;

@Service
public class CustomUserDetails implements UserDetailsService {
    @Autowired
    CustomerRepository customerRepository;
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
       Optional<Customer> customer= customerRepository.findByEmail(email);
       if(!customer.isPresent()){
           throw new  ResourceNotFound("user with email address doesnot exist");
       }else {
           return new User(customer.get().getEmail(),customer.get().getPassword(),new ArrayList<>());

       }


    }
}
