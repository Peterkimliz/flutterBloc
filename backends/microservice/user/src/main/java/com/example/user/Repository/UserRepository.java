package com.example.user.Repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.user.Models.UserModel;
@Repository
public interface UserRepository extends JpaRepository<UserModel,Integer>{
    Optional<UserModel> findByEmail(String email);
    
}
