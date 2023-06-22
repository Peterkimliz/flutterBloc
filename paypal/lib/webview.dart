import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatelessWidget {
  final url;

  const WebviewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            print("the ${request.url}");
            if (request.url
                .contains("https://testenterprises.com/merchantonboarde")) {
              print("url is${request.url}");
              Uri uri =  Uri.dataFromString(request.url);
              String? codeParam = uri.queryParameters['merchantIdInPayPal'];
              print("url is ${codeParam}");
              Get.back();
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
