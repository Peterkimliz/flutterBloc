package com.example.StoreApi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;
import java.util.Date;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AddressDto {
    @NotBlank(message = "state required ")
    private String state;
    @NotBlank(message = "city required ")
    private String city;
    @NotBlank(message = "pincode required ")
    private String pincode;

}
