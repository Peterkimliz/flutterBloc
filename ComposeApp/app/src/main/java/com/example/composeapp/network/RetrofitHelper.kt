package com.example.composeapp.network

import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitHelper {
 private const val BASE_URL="";

 fun getRetrofitInstance():Retrofit{
     val retrofit=Retrofit
         .Builder()
         .baseUrl(BASE_URL)
         .addConverterFactory(GsonConverterFactory.create())
         .build()
     return  retrofit;
 }

}