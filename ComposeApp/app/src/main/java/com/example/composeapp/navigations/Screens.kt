package com.example.composeapp.navigations

sealed class Screens(val route:String){

    object  LoginPage: Screens("login_screen")
    object  RegisterPage: Screens("register_screen")
}
