package com.example.StoreApi.services;

import com.example.StoreApi.dto.CartDto;
import com.example.StoreApi.models.Cart;
import com.example.StoreApi.models.Customer;
import com.example.StoreApi.models.Product;
import com.example.StoreApi.repository.CartRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class CartService {
    @Autowired
    ProductService productService;
    @Autowired
    CustomerService customerService;
    @Autowired
    CartRepository cartRepository;

    public Cart createCart(CartDto cartDto){
       Customer customer=customerService.getCustomerById(cartDto.getCustomerId()) ;
       Product product=productService.getProductById(cartDto.getProductId());
       Cart cart=new Cart();
       cart.setCreatedAt(new Date(System.currentTimeMillis()));
       cart.setUpdatedAt(new Date(System.currentTimeMillis()));
       cart.setCustomer(customer);
       cart.setProduct(product);
       cart.setQuantity(cartDto.getQuantity());
      return cartRepository.save(cart);
    }


}
