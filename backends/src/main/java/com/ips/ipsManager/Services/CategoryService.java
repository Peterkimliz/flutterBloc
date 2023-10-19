package com.ips.ipsManager.Services;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ips.ipsManager.Dtos.CategoryDto;
import com.ips.ipsManager.Exceptions.FoundException;
import com.ips.ipsManager.Models.Category;
import com.ips.ipsManager.Repositories.CategoryRepository;


@Service
public class CategoryService {

    @Autowired
    CategoryRepository categoryRepository;

    public CategoryDto createCategory(CategoryDto categoryDto) {
        Optional<Category> foundCategory = categoryRepository.findByIpAddress(categoryDto.getIpAddress());
        if (foundCategory.isPresent()) {
            throw new FoundException("IpAddress already");
        }
        Category category = Category.builder().ipAddress(categoryDto.getIpAddress()).status(categoryDto.getStatus()).build();
        categoryRepository.save(category);
        categoryDto.setId(category.getId());
        return categoryDto;
    }

    public CategoryDto getCategoryById(String id) {
        Optional<Category> foundCategory = categoryRepository.findById(id);
        if (!foundCategory.isPresent()) {
            throw new FoundException("IpAddress not found");
        }
        Category category=foundCategory.get();
        return CategoryDto.builder().id(category.getId()).ipAddress(category.getIpAddress()).status(category.getStatus()).build();

    }

    // public CategoryDto updateCategoryById(CategoryDto categoryDto, String id) {
    //     Optional<Category> foundCategory = categoryRepository.findById(id);
    //     if (!foundCategory.isPresent()) {
    //         throw new FoundException(" not found");
    //     }
    //     Category category = foundCategory.get();
    //     category.setName(categoryDto.getName() == null ? category.getName() : categoryDto.getName());
    //     category.setType(categoryDto.getType() == null ? category.getType() : categoryDto.getType());
    //     categoryRepository.save(category);

    //     return CategoryDto.builder().id(category.getId()).name(category.getName()).type(category.getType()).build();

    // }



    public List<CategoryDto> getAllCategories(String type) {
    
        List<Category> categories = categoryRepository.findByType(type);
        if (categories.size() > 0) {
            return categories.stream().map(e -> CategoryDto.builder().id(e.getId()).ipAddress(e.getIpAddress()).status(e.getStatus()).build()).toList();

        } else {
            return new ArrayList<>();
        }

    }

}
