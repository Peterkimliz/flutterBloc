package com.example.composeapp.network

import com.example.composeapp.model.Product
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Path
import retrofit2.http.Query

interface RecipeService {
    @GET("search")
    suspend fun  search(
        @Header("Autorization") token:String,
        @Query("page") page:Int,
        @Query("name") name:String):Response<List<Product>>

    @GET("product")
    suspend fun getProducts(@Header("Authorization") token:String):Response<List<Product>>

    //get product by id method

    @GET("products/{id}")
    suspend fun getProductById(@Path("id") id:String):Response<Product>



}