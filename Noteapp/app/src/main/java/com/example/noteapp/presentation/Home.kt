package com.example.noteapp.presentation

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.FloatingActionButtonDefaults
import androidx.compose.material3.FloatingActionButtonElevation
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Shapes
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavHostController
import com.example.noteapp.presentation.components.AppBar
import com.example.noteapp.presentation.navigation.Navigation

@Composable
fun Home(navHostController: NavHostController) {
    Scaffold(
        topBar = {
            AppBar(title = "Home", navHostController = navHostController)
        },
        bottomBar = {

        },
        floatingActionButton = {
            FloatingActionButton(
                containerColor = MaterialTheme.colorScheme.primary,
                shape = FloatingActionButtonDefaults.largeShape ,
                elevation = FloatingActionButtonDefaults.elevation(13.dp),
                onClick = {
                    navHostController.navigate(route = Navigation.AddNote.route)
                }) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = "Add note ",
                    tint = Color.White
                )

            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(text = "Hello there")
        }
    }


}

