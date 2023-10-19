package com.example.StoreApi.models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.Date;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "address")
public class Address {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String state;
    private String city;
    private String pincode;
    private Date createdAt;
    private Date updatedAt;
    @ManyToOne
    @JoinColumn(name = "customer")
    private Customer customer;

}
