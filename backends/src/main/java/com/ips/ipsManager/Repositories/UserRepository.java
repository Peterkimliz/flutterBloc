package com.ips.ipsManager.Repositories;

import java.util.Optional;

import org.springframework.stereotype.Repository;

import com.ips.ipsManager.Models.UserModel;

@Repository
public interface UserRepository  extends MongoRepository<UserModel,String>{

    Optional<UserModel> findByEmail(String email);
}
