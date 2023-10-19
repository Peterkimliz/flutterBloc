package com.example.StoreApi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;
import java.util.Date;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductDto {
    @NotBlank(message = "product name required ")
    private String productName;
    @NotBlank(message = "product image required ")
    private String productImage;
    @NotBlank(message = "product description required ")
    private String productDescription;
   @NotBlank(message = "product quantity required ")
    private String  productQuantity;
  @NotBlank(message = "product price required ")
    private String productPrice;

}
