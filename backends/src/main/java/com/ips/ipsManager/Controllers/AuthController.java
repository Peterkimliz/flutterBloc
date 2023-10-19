package com.ips.ipsManager.Controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ips.ipsManager.Dtos.LoginRequest;
import com.ips.ipsManager.Dtos.LoginResponse;
import com.ips.ipsManager.Dtos.SigninRequests;
import com.ips.ipsManager.Services.AuthService;

import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("api/v1/auth")
@Tag(name = "Authenticatin")
public class AuthController {

    @Autowired
    AuthService authService;

    @PostMapping("/signup")
    public ResponseEntity<LoginResponse> signUpUser(@RequestBody @Validated SigninRequests  signinRequests){
        return new ResponseEntity<LoginResponse>(authService.createUser(signinRequests),HttpStatus.CREATED);
    }

    @PostMapping("/signin")
    public ResponseEntity<LoginResponse> signInUser(@RequestBody LoginRequest loginRequest){
        return new ResponseEntity<LoginResponse>(authService.LoginUser(loginRequest),HttpStatus.OK);
    }

    
}
