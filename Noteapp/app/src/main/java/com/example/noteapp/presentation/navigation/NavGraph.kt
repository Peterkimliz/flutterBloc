package com.example.noteapp.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import com.example.noteapp.presentation.AddNote
import com.example.noteapp.presentation.Home

@Composable
fun NavigationGraph(
    navigation: NavHostController
) {
    NavHost(navController = navigation, startDestination = Navigation.Home.route) {
        composable(route = Navigation.Home.route) {
            Home(navHostController = navigation)
        }
        composable(route = Navigation.AddNote.route) {
            AddNote(navHostController = navigation)
        }
    }

}