package com.example.StoreApi.models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.Date;


@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "products")
public class Product {
    @Id
    @SequenceGenerator(
            name = "product_sequence",
            sequenceName = "product_sequence",
            allocationSize = 1
    )
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE
            , generator = "product_sequence"

    )
    private Long id;
    private String productName;
    private String productImage;
    private String productDescription;
    private String productQuantity;
    private String productPrice;
    private Date createdAt;
    private Date updatedAt;
    @ManyToOne
    @JoinColumn(name = "customer")
    private Customer customer;
}
