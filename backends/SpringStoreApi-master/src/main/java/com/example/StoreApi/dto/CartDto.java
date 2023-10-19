package com.example.StoreApi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CartDto {
    @NotBlank(message = "Customer id required ")
    private Long customerId;
    @NotBlank(message = " product id required ")
    private Long productId;
    @NotBlank(message = "Quantity required")
    private int quantity;
}
