package com.example.composeapp.views.auth.widgets

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.example.composeapp.R
@Composable
fun LoginSocial(){
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Divider(modifier = Modifier.width(150.dp))
        Text(
            text = "Or",
            color = Color.Black,
            modifier = Modifier.padding(horizontal = 3.dp, vertical = 0.dp)
        )

        Divider(modifier = Modifier.width(150.dp))
    }
    Spacer(modifier = Modifier.height(20.dp))

    Row(
        modifier = Modifier.fillMaxWidth(),

        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center
    ) {
        IconButton(
            onClick = { /*TODO*/ },
            modifier = Modifier
                .height(100.dp)
                .width(100.dp),

            ) {
            Icon(
                modifier = Modifier
                    .height(40.dp)
                    .width(40.dp),
                painter = painterResource(
                    id = R.drawable.google
                ),
                contentDescription = ""
            )

        }
        IconButton(onClick = { /*TODO*/ }) {
            Icon(
                modifier = Modifier
                    .height(50.dp)
                    .width(50.dp),
                painter = painterResource(id = R.drawable.facebook),
                contentDescription = ""
            )

        }

    }
}