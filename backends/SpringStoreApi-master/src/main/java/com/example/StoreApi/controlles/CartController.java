package com.example.StoreApi.controlles;

import com.example.StoreApi.dto.CartDto;
import com.example.StoreApi.models.Cart;
import com.example.StoreApi.services.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("api/v1/cart")
public class CartController {
    @Autowired
    CartService cartService;
    @PostMapping
    public ResponseEntity<Cart> createCart(@RequestBody CartDto cartDto){
        return new ResponseEntity<Cart>(cartService.createCart(cartDto), HttpStatus.CREATED);
    }
}
