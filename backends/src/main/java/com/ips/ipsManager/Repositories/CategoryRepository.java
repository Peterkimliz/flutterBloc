package com.ips.ipsManager.Repositories;

import org.springframework.stereotype.Repository;

import com.ips.ipsManager.Models.Category;
import com.ips.ipsManager.Repositories.CategoryRepository;

import java.util.List;
import java.util.Optional;


@Repository
public interface CategoryRepository extends MongoRepository<Category,String> {

    Optional<Category> findByName(String id);

    List<Category> findByType(String type);

    Optional<Category> findByIpAddress(String ipAddress);
    
}
