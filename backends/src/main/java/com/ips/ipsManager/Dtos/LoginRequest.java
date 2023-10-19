package com.ips.ipsManager.Dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class LoginRequest {
      @NotBlank(message = "Please enter email")
    private String email;
      @NotBlank(message = "Please enter password")
    private String password;
}
