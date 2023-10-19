package com.ips.ipsManager.Models;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import com.fasterxml.jackson.annotation.JsonIgnore;

import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder
@Document(collection = "users")

public class UserModel {
    @Id
    private String id;
    private String customerName;
    private String email;
    private String phone;
    @JsonIgnore
    private String password;


    
}
