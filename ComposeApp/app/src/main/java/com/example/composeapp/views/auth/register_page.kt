package com.example.composeapp.views.auth

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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.composeapp.views.auth.widgets.Inputs
import com.example.composeapp.views.auth.widgets.LoginSocial
import com.example.composeapp.views.auth.widgets.PassworddInput

@Composable
fun RegisterPage() {
    var userName by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var phone by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var c_password by remember { mutableStateOf("") }
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(30.dp))
        Text(
            text = "Create Account",
            fontSize = 25.sp,
            textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(20.dp))
        Inputs(placeHolderText = "username")
        Spacer(modifier = Modifier.height(15.dp))
        Inputs(placeHolderText = "email")
        Spacer(modifier = Modifier.height(15.dp))
        Inputs(placeHolderText = "phone")
        Spacer(modifier = Modifier.height(15.dp))
        Inputs(placeHolderText = "email", isEmail = true)
        Spacer(modifier = Modifier.height(15.dp))
        PassworddInput()
        Spacer(modifier = Modifier.height(15.dp))
        PassworddInput()
        Spacer(modifier = Modifier.height(15.dp))
        Button(onClick = { /*TODO*/ }) {
            Text(text = "Sign up", fontSize = 16.sp, modifier = Modifier.padding(40.dp,10.dp))

        }
        Spacer(modifier = Modifier.height(15.dp))
        Row(
            horizontalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                text = "Already Have Account?",
                fontSize = 18.sp
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(text = "Sign Up", fontSize = 18.sp, color = Color.Blue)
        }
        Spacer(modifier = Modifier.height(20.dp))
        LoginSocial()


    }

}