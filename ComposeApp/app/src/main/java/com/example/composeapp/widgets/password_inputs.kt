package com.example.composeapp.widgets

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import com.example.composeapp.R


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PassworddInput() {
    var showPassword by remember { mutableStateOf(false) }
    var passwordValue by remember { mutableStateOf("") }
    OutlinedTextField(
        value = passwordValue,
        onValueChange = { newValue ->
            passwordValue = newValue
        },
        placeholder = {
            Text(text = "Password")
        },
        modifier = Modifier.fillMaxWidth(),
        keyboardOptions = KeyboardOptions(
            keyboardType = KeyboardType.Password,
            imeAction = ImeAction.Done
        ),
        visualTransformation = if (showPassword)
            VisualTransformation.None
        else
            PasswordVisualTransformation(),
        trailingIcon = {
            IconButton(onClick = {
                showPassword = !showPassword
            }) {
                Icon(
                    tint = Color.LightGray,
                    painter = painterResource(
                        id = if (showPassword)
                            R.drawable.visibility
                        else
                            R.drawable.visibility_off
                    ),
                    contentDescription = ""
                )

            }

        }

    )


}

@Composable
@Preview(showBackground = true)
fun PasswordInputPreview() {
    PassworddInput()
}