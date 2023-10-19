package com.example.user.Services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.user.Repository.UserRepository;

@Service
public class UserService {

    @Autowired
    UserRepository userRepository;
    
}
