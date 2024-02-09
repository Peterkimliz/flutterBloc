package com.example.noteapp.presentation.navigation

sealed class Navigation(var route:String){
    object Home:Navigation(route = "home")
    object AddNote:Navigation(route = "addNote")
}