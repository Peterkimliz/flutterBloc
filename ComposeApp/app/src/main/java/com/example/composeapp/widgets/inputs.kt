package com.example.composeapp.widgets

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.tooling.preview.Preview


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Inputs(placeHolderText: String, isEmail: Boolean = false) {
    var value by remember { mutableStateOf("") }
    OutlinedTextField(
        value = value,
        onValueChange =
        { newValue -> value = newValue },
        placeholder = { Text(text = placeHolderText) },
        modifier = Modifier.fillMaxWidth(),
//        leadingIcon = {
//            IconButton(
//                onClick = { /*TODO*/ })
//            {
//            }
//        },
        keyboardOptions = KeyboardOptions(
            keyboardType =
            if (isEmail)
                KeyboardType.Email else KeyboardType.Text,
            imeAction = ImeAction.Next
        )


    )

}

@Composable
@Preview(showBackground = true)
fun ShowInputsPreview() {
    Inputs(placeHolderText = "Email");
}