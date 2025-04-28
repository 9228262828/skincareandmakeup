import 'package:Gomla/contstants.dart';
import 'package:Gomla/screens/main_screen.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../shared/components/toast_component.dart';
import '../widgets/app_bar.dart';
import 'dart:io';

class PaymentPage extends StatefulWidget {
  final String id;
  final String orderKey;

  PaymentPage({required this.id, required this.orderKey});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late InAppWebViewController _webViewController;
  bool _isHeaderVisible = false;

  late String selectedUserAgent;

  @override
  void initState() {
    super.initState();

    final safariUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1";
    final chromeUserAgent = "Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Mobile Safari/537.36";

    if (Platform.isIOS) {
      selectedUserAgent = safariUserAgent;
    } else if (Platform.isAndroid) {
      selectedUserAgent = chromeUserAgent;
    } else {
      selectedUserAgent = chromeUserAgent; // Default
    }

    Future.delayed(Duration(seconds: 4), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentUrl =
        'https://gomla.sa/checkout/order-pay/${widget.id}/?pay_for_order=true&key=${widget.orderKey}';

    return Scaffold(
      appBar: CustomPagesAppBar(
          title: AppLocalizations.of(context)!.payment, home: false),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: mediaQueryHeight(context) * 0.2),
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(paymentUrl)),
                  initialSettings: InAppWebViewSettings(
                    userAgent: selectedUserAgent,
                    javaScriptEnabled: true,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                    print("✅ WebView Created with UserAgent: $selectedUserAgent");
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print("Console Message: ${consoleMessage.message}");
                    if (consoleMessage.message == 'doneeeeeee') {
                      print("doneeeeeee");
                      // After receiving the message, proceed to hide unnecessary elements
                      _hideUnnecessaryElements();
                    }
                  },
                  onLoadStart: (controller, url) async {
                    await _hideUnnecessaryElements();
                  },
                  onLoadStop: (controller, url) async {
                    await _hideUnnecessaryElements();
                    _handlePaymentCompletion(url.toString());
                  },
                  onLoadError: (controller, url, code, message) {
                    print('Error loading page: $message');
                    showToast(
                        text: AppLocalizations.of(context)!.initializationFailed,
                        state: ToastStates.ERROR);
                  },
                ),
              ),
            ],
          ),
          // Show the spinner until header and footer are hidden
          if (!_isHeaderVisible)
            Container(
              height: mediaQueryHeight(context),
              width: mediaQueryWidth(context),
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  color: mainColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _hideUnnecessaryElements() async {
    if (_webViewController != null) {
      await _webViewController.evaluateJavascript(source: """
      (function() {
        var header = document.querySelector('header');
        var footer = document.querySelector('footer');
        var shopTable = document.querySelector('.shop_table');
        var method = document.querySelector('.payment_method_neoleap');
        var cashOnDelivery = document.querySelector('.payment_method_cod'); // Cash on delivery option
        var creditCardMethod = document.querySelector('.payment_method_credit_card'); // Example of a Credit Card payment option

        // Hide unnecessary elements
        if (header) header.style.display = 'none';
        if (footer) footer.style.display = 'none';
        if (shopTable) shopTable.style.display = 'none';
        if (method) method.style.display = 'block';

        // Hide the Cash on Delivery option
        if (cashOnDelivery) {
          cashOnDelivery.style.display = 'none'; 
        }

        // Select the Credit Card payment option
        if (creditCardMethod) {
          creditCardMethod.checked = true; // This selects the radio button or checkbox
        }
      })()
    """);

      print('✅ Unnecessary elements hidden, and Credit Card selected');

      // Adding a 2-second delay before removing the spinner
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isHeaderVisible = true;
      });
    }
  }

  void _handlePaymentCompletion(String url) {
    if (url.contains('payment-success') || url.contains('order-received')) {
      showToast(
        text: AppLocalizations.of(context)!.order_placed_successfully,
        state: ToastStates.SUCCESS,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(index: 0)),
            (route) => false,
      );
    }
  }
}
