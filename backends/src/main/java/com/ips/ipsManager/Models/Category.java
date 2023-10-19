package com.ips.ipsManager.Models;



import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DocumentReference;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Document(collection = "categories")

public class Category {
    @Id
    private String id;
    private String ipAddress;
    private String status;
    @DocumentReference(lazy = true)
    private UserModel userModel;
}
