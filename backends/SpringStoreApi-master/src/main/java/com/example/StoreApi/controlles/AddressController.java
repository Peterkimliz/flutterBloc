package com.example.StoreApi.controlles;

import com.example.StoreApi.dto.AddressDto;
import com.example.StoreApi.dto.ProductDto;
import com.example.StoreApi.models.Address;
import com.example.StoreApi.models.Product;
import com.example.StoreApi.services.AddressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/v1/address")
public class AddressController {
    @Autowired
    AddressService addressService;
    @PostMapping("/{uid}")
    public ResponseEntity<Address> createAddress(@PathVariable("uid") Long uid , @RequestBody  @Validated AddressDto addressDto){
        return new ResponseEntity<Address>(addressService.createAddress(addressDto,uid), HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<Address>> getProduct(){
        List<Address> addresses= addressService.getAddresses();
        return new ResponseEntity<List<Address>>(addresses, addresses.size()==0?HttpStatus.NOT_FOUND:HttpStatus.OK);
    }
    @GetMapping("/{id}")
    public ResponseEntity<Address> getProductById(@PathVariable("id") Long id){
        return new ResponseEntity<Address>(addressService.getAddressById(id), HttpStatus.OK);
    }
    //@PutMapping("/{id}")

//    public ResponseEntity<Customer> updateCustomerById(@PathVariable("id") Long id, @RequestBody Customer customer){
//        return new ResponseEntity<Customer>(productService.updateCustomerById(id,customer), HttpStatus.OK);
//    }
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProductById(@PathVariable("id") Long id){
        addressService.deleteAddressById(id);
        return new ResponseEntity<>("Address deleted Successfully", HttpStatus.OK);
    }
}
