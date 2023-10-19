package com.ips.ipsManager.Controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.ips.ipsManager.Dtos.UserResponse;
import com.ips.ipsManager.Services.UserService;

import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("api/v1/users")
@Tag(name = "Users")
public class UserController {
    @Autowired
    private UserService userService;

    @GetMapping("{userId}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable("userId") String userId) {
        return new ResponseEntity<UserResponse>(userService.getUserById(userId), HttpStatus.OK);
    }
    @GetMapping("/all")
    public ResponseEntity<List<UserResponse>> getAllUsers(@RequestParam(required = true) int pageNumber) {
        return new ResponseEntity<List<UserResponse>>(userService.allUsers(pageNumber), HttpStatus.OK);
    }

}
