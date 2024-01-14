package com.example.composeapp.model

import com.google.gson.annotations.SerializedName

data class Product(
    @SerializedName("id")
    val id:String,
    @SerializedName("name")
    val name:String,
    @SerializedName("image")
    val image:String,
    @SerializedName("price")
    val price :Int,
    @SerializedName("quantity")
    val quantity:Int,
    @SerializedName("quantity")
    val description:String
)
