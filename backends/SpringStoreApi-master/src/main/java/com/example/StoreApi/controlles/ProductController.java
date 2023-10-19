package com.example.StoreApi.controlles;

import com.example.StoreApi.dto.ProductDto;
import com.example.StoreApi.models.Product;
import com.example.StoreApi.services.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/v1/product")
public class ProductController {
    @Autowired
    ProductService productService;

    @PostMapping("/{uid}")
    public ResponseEntity<Product> createProduct(@PathVariable("uid") Long uid, @RequestBody @Validated ProductDto productDto) {
        return new ResponseEntity<Product>(productService.createProduct(productDto, uid), HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<Product>> getProduct() {
        List<Product> products = productService.getAllProducts();
        return new ResponseEntity<List<Product>>(products, products.size() == 0 ? HttpStatus.NOT_FOUND : HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable("id") Long id) {
        return new ResponseEntity<Product>(productService.getProductById(id), HttpStatus.OK);
    }
    //       @PutMapping("/{id}")

    //    public ResponseEntity<Customer> updateCustomerById(@PathVariable("id") Long id, @RequestBody Customer customer){
//        return new ResponseEntity<Customer>(productService.updateCustomerById(id,customer), HttpStatus.OK);
//    }
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProductById(@PathVariable("id") Long id) {
        productService.deleteProductById(id);
        return new ResponseEntity<>("Product deleted Successfully", HttpStatus.OK);
    }
}
