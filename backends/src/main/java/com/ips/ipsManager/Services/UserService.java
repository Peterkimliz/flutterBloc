package com.ips.ipsManager.Services;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springdoc.core.converters.models.Pageable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.stereotype.Service;

import com.ips.ipsManager.Dtos.UserResponse;
import com.ips.ipsManager.Exceptions.NotFoundException;
import com.ips.ipsManager.Models.UserModel;
import com.ips.ipsManager.Repositories.UserRepository;

@Service
public class UserService {
    @Autowired
    UserRepository userRepository;

    public UserResponse getUserById(String userId) {
        Optional<UserModel> foundUser = userRepository.findById(userId);
        if (!foundUser.isPresent()) {
            throw new NotFoundException("User with the id not found");
        }
        UserModel userModel = foundUser.get();
        UserResponse userResponse = mapToUserDto(userModel);
        return userResponse;

    }

    private UserResponse mapToUserDto(UserModel userModel) {
        return UserResponse.builder()

                .email(userModel.getEmail())
                  .id(userModel.getId())
                .customerName(userModel.getCustomerName())
                .build();
    }

    public List<UserResponse> allUsers(int pageNumber) {
        PageRequest pageable = PageRequest.of(pageNumber, 15).withSort(Direction.DESC, "CreatedAt");
        List<UserModel> users = userRepository.findAll(pageable).toList();
        if (users.isEmpty()) {
            return new ArrayList<>();

        }
        return users.stream().map(e -> mapToUserDto(e)).toList();
    }

}
