package com.example.noteapp.presentation
import android.widget.Toast
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.FloatingActionButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.navigation.NavHostController
import com.example.noteapp.presentation.components.AppBar

@Composable
fun AddNote(navHostController: NavHostController) {
    val mContext=LocalContext.current;
    Scaffold(
        topBar = {
            AppBar(
                title = "Add  Note", showLeading = true,
                navHostController = navHostController
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                containerColor = MaterialTheme.colorScheme.primary,
                elevation = FloatingActionButtonDefaults.elevation(12.dp),
                shape = FloatingActionButtonDefaults.largeShape,
                onClick = {
                    Toast.makeText(mContext,"Saving note",Toast.LENGTH_LONG).show()
                }) {
                Icon(imageVector = Icons.Default.Check, contentDescription = "Save")
            }
        },
        content = { it ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(it)
            ) {

            }
        }
    )

}