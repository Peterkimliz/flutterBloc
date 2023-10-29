package com.example.composeapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.BaselineShift
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.composeapp.views.auth.LoginPage

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {


            LoginPage()
        }
    }

    @Composable
    fun MainContent() {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFFF2F2F2)),
        ) {
            Image(
                painter = painterResource(id = R.drawable.logo),
                contentDescription = "",
                modifier = Modifier
                    .height(200.dp)
                    .fillMaxWidth(),
                contentScale = ContentScale.Crop
            )
            Column(
                modifier = Modifier
                    .padding(10.dp)
                    .fillMaxWidth()
            ) {
                Row(
                    horizontalArrangement = Arrangement.SpaceBetween,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = "Happy Meal", style = TextStyle(
                            color = Color.Black,
                            fontWeight = FontWeight.Bold,

                            )
                    )
                    Text(
                        text = "$50", style = TextStyle(
                            color = Color.Green,

                            )
                    )
                }
                Spacer(modifier = Modifier.padding(top = 10.dp))
                Text(text = "800 Calorie")
                Spacer(modifier = Modifier.padding(top = 10.dp))
                Text(
                    buildAnnotatedString {
                        withStyle(
                            style = SpanStyle(
                                fontSize = MaterialTheme.typography.bodyLarge.fontSize

                            )
                        ) {
                            append("20")
                        }
                        withStyle(
                            style = SpanStyle(
                                baselineShift = BaselineShift.Superscript

                            )
                        ) {
                            append("c")
                        }
                    }
                )


                Spacer(modifier = Modifier.padding(top = 20.dp))
                Button(

                    onClick = {},
                    modifier = Modifier.align(Alignment.CenterHorizontally)
                )
                {
                    Text(text = "order now".uppercase())
                }


            }
        }

    }


    @Preview(showBackground = true)

    @Composable
    fun ShowPreview() {
        MainContent();
    }

}
