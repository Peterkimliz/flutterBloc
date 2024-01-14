package com.example.composeapp.viewModel

import androidx.lifecycle.ViewModel
import com.example.composeapp.network.RecipeService
import com.example.composeapp.network.RetrofitHelper
import retrofit2.Retrofit

class ProductViewModel : ViewModel() {
    lateinit var retrofit: Retrofit;
    init {
        retrofit = RetrofitHelper.getRetrofitInstance();
    }

    suspend fun getAllProducts() {
        var products = retrofit.create(RecipeService::class.java).getProducts(token = "");

    }


}