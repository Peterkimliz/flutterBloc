package com.example.StoreApi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CustomerEntity {
    @NotBlank(message = "username required ")
    private String username;
    @NotBlank(message = "email required ")
    private String email;
    @NotBlank(message = "phone required ")
    private String phone;
    @NotBlank(message = "password required ")
    private String password;

}
