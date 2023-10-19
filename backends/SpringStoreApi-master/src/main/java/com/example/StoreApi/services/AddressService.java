package com.example.StoreApi.services;

import com.example.StoreApi.Exceptions.ResourceNotFound;
import com.example.StoreApi.dto.AddressDto;
import com.example.StoreApi.models.Address;
import com.example.StoreApi.models.Customer;
import com.example.StoreApi.repository.AddressRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
public class AddressService {
    @Autowired
    private AddressRepository addressRepository;
    @Autowired
    private CustomerService customerService;

    public Address createAddress(AddressDto addressDto,Long id){
        Customer customer=customerService.getCustomerById(id);
        Address address=new Address();
        address.setCreatedAt(new Date(System.currentTimeMillis()));
        address.setUpdatedAt(new Date(System.currentTimeMillis()));
        address.setCity(addressDto.getCity());
        address.setPincode(addressDto.getPincode());
        address.setState(addressDto.getState());
        addressDto.setState(addressDto.getState());
        address.setCustomer(customer);
        return addressRepository.save(address);
    }
    public List<Address> getAddresses(){
        List<Address> address=addressRepository.findAll();
        if (address.size()==0){
            return new ArrayList<>();
        }else{

            return address;
        }
    }
    public Address getAddressById(Long id){
        Optional<Address> address=addressRepository.findById(id);
        if (!address.isPresent()){
          throw new ResourceNotFound("Address with the given id doesn't exist");
        }else{
            return address.get();
        }
    }
    public void deleteAddressById(Long id){
        Optional<Address> address=addressRepository.findById(id);
        if (!address.isPresent()){
          throw new ResourceNotFound("Address with the given id doesn't exist");
        }else{
         addressRepository.deleteById(id);
        }
    }

}
