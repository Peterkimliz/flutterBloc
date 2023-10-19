package com.example.StoreApi.services;

import com.example.StoreApi.Exceptions.ResourceNotFound;
import com.example.StoreApi.dto.AddressDto;
import com.example.StoreApi.dto.ProductDto;
import com.example.StoreApi.models.Address;
import com.example.StoreApi.models.Customer;
import com.example.StoreApi.models.Product;
import com.example.StoreApi.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;
@Service
public class ProductService {
    @Autowired
    private ProductRepository productRepository;
    @Autowired
    private CustomerService customerService;

    public Product createProduct(ProductDto productDto, Long id){
        Customer customer=customerService.getCustomerById(id);
        Product product=new Product();
        product.setCreatedAt(new Date(System.currentTimeMillis()));
        product.setUpdatedAt(new Date(System.currentTimeMillis()));
        product.setProductName(productDto.getProductName());
        product.setProductDescription(productDto.getProductDescription());
        product.setProductImage(productDto.getProductImage());
        product.setProductPrice(productDto.getProductPrice());
        product.setProductQuantity(productDto.getProductQuantity());
        System.out.println("helllo"+productDto.getProductQuantity());
        product.setCustomer(customer);
        return productRepository.save(product);

    }
    public List<Product> getAllProducts(){
        List<Product> products= productRepository.findAll();
        if (products.size()==0){
            return new ArrayList<>();
        }else{

            return products;
        }
    }
    public Product getProductById(Long id){
        Optional<Product> product= productRepository.findById(id);
        if (!product.isPresent()){
            throw new ResourceNotFound("product with the given id doesn't exist");
        }else{
            return product.get();
        }
    }
    public void deleteProductById(Long id){
        Optional<Product> product= productRepository.findById(id);
        if (!product.isPresent()){
            throw new ResourceNotFound("product with the given id doesn't exist");
        }else{
            productRepository.deleteById(id);
        }
    }
}
