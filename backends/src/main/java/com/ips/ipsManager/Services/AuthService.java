package com.ips.ipsManager.Services;

import java.util.Date;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.ips.ipsManager.Dtos.LoginRequest;
import com.ips.ipsManager.Dtos.LoginResponse;
import com.ips.ipsManager.Dtos.SigninRequests;
import com.ips.ipsManager.Dtos.UserResponse;
import com.ips.ipsManager.Exceptions.FoundException;
import com.ips.ipsManager.Exceptions.NotFoundException;
import com.ips.ipsManager.Models.UserModel;
import com.ips.ipsManager.Repositories.UserRepository;
import com.ips.ipsManager.Security.JwtService;
import com.ips.ipsManager.Security.UserDetailsImplementation;





@Service
public class AuthService {
    @Autowired
    UserRepository userRepository;
    @Autowired
    PasswordEncoder passwordEncoder;
    @Autowired
    JwtService jwtService;
    @Autowired
    UserDetailsImplementation userDetailsImplementation;
     @Autowired
    AuthenticationManager authenticationManager;



    public LoginResponse createUser(SigninRequests signinRequests) {
        Optional<UserModel> foundUser = userRepository.findByEmail(signinRequests.getEmail());
        if (foundUser.isPresent()) {
            throw new FoundException("User with email address already exists");
        }
        UserModel userModel = UserModel.builder()
               
                .email(signinRequests.getEmail())
            
                .phone(signinRequests.getPhone())
                .password(passwordEncoder.encode(signinRequests.getPassword())).customerName(signinRequests.getUsername()).build();

        userRepository.save(userModel);

        LoginResponse loginResponse = buildLoginResponse(userModel);

        return loginResponse;

    }

     public LoginResponse LoginUser(LoginRequest loginRequest) {
       
            try {
                authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(loginRequest.getEmail(), loginRequest.getPassword())
                );
    
            } catch (Exception e) {
                System.out.println(e);
                throw new NotFoundException("invalid email or password");
            }
            Optional<UserModel> user = userRepository.findByEmail(loginRequest.getEmail());
            LoginResponse loginResponse = buildLoginResponse(user.get());
            return loginResponse;
    
    }
    

    private LoginResponse buildLoginResponse(UserModel userModel) {

        UserResponse userResponse = UserResponse.builder()
                .email(userModel.getEmail()).customerName(userModel.getCustomerName())
                .id(userModel.getId()).build();
        UserDetails userDetails = userDetailsImplementation.loadUserByUsername(userModel.getEmail());
        System.out.println(userDetails);
        String token = jwtService.buildToken(userDetails);
        return LoginResponse.builder().token(token).userResponse(userResponse).build();
    }

}
