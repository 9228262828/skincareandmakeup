import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../shared/utils/app_values.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final String url;
  final String title;

  PrivacyPolicyScreen({required this.url, required this.title});
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Column(
          children: [
             Container(
              height: mediaQueryHeight(context) * 0.1,
              decoration: BoxDecoration(
                color: Color(0xFF212224),
                borderRadius: BorderRadius.only(


                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(  horizontal: 8.0 ,vertical: 4),
                child: Column(
                  children: [
                    SizedBox(height: mediaQueryHeight(context) * 0.04,),
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0.0, right: 8.0),
                              child: Icon(Icons.arrow_back_ios, color: mainColor, size: 25),
                            )),
                     ]),
                  ],
                ),
              )
            ),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                // this i the our website link
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },

                onLoadStart: (controller, url) async {
                  await webViewController?.evaluateJavascript(source: """
                      var header = document.querySelector('header');
                      var footer = document.querySelector('footer');
                      if (header) header.style.display = 'none';
                      if (footer) footer.style.display = 'none';
                    """);
                  print('Started loading: $url');
                },
                onLoadStop: (controller, url) async {
                  print('Finished loading: $url');
                  await webViewController?.evaluateJavascript(source: """
                      var header = document.querySelector('header');
                      var method = document.querySelector('.payment_method_neoleap');
                      var footer = document.querySelector('footer');
                      if (header) header.style.display = 'none';
                      if (footer) footer.style.display = 'none';
                      if (method) method.style.display = 'block';
                    """);
                },
              ),
            ),
          ],
        )

    );
  }
}
