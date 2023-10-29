package com.example.composeapp.views.auth

import android.util.Log
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.composeapp.widgets.Inputs
import com.example.composeapp.widgets.PassworddInput

@Composable
fun LoginPage() {
    Column(
        modifier = Modifier
            .padding(20.dp)
            .fillMaxSize(), verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {

        Text(
            text = "LoginPage",
            fontWeight = FontWeight.Bold,
            fontSize = 30.sp,
            style = TextStyle(
                color = Color.Black
            )
        )
        Spacer(modifier = Modifier.height(20.dp))
        Inputs(placeHolderText = "Email", isEmail = true)
        Spacer(modifier = Modifier.height(20.dp))
        PassworddInput()
        Spacer(modifier = Modifier.height(15.dp))
        Text(
            text = "Forgot Password?",
            modifier = Modifier.fillMaxWidth(),
            style = TextStyle(
                color = Color.Blue,
                textAlign = TextAlign.Right,
                textDecoration = TextDecoration.Underline
            )
        )
        Spacer(modifier = Modifier.height(15.dp))
        Button(onClick = { /*TODO*/
            Log.d("hello", "printed")
        }) {
            Text(text = "Login")

        }
        Spacer(modifier = Modifier.height(15.dp))

        Row(
            horizontalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                text = "Dont Have Account?",
                fontSize = 18.sp
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
                text = "Sign Up", fontSize = 18.sp, color = Color.Blue
            )
        }


    }
}

@Composable
@Preview
fun LoginPagePreview() {
    LoginPage();
}