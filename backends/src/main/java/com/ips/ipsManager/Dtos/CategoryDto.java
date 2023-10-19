package com.ips.ipsManager.Dtos;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CategoryDto {
    @NotBlank(message = "ipAddress required")
    private String ipAddress; 
    @NotBlank(message = "status required")
    private String status;
    private String id;
    
}
