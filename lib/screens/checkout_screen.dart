import 'package:flutter/material.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkLocale.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contstants.dart';
import '../env.dart';
import '../main.dart';
import '../models/cart.dart';
import '../services/auth_service.dart';
import '../services/woocommerce_service.dart';
import '../widgets/app_bar.dart';
import 'main_screen.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Map<String, dynamic>? _userInfo;
  double _totalAmount = 0.0;
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _country = 'Egypt';
  String _address = '';
  String _city = '';
  String _state = '';
  String _phone = '';
  String _email = '';
  String _orderNotes = '';
  String _paymentMethod = 'cod';
  String _couponCode = '';
  double _shippingCost = 0.0;
  double _discountAmount = 0.0;

  final Map<String, double> _cityShippingCosts = {
    "TEST": 1,
    "Cairo, Giza": 49,
    "Alexandria": 55,
    "Beheira": 60,
    "Dakahlia": 60,
    "Damietta": 60,
    "Gharbia": 60,
    "Qalyubia": 60,
    "Kafr el-Sheikh": 60,
    "Monufia": 60,
    "Al Sharqia": 60,
    "Ismailia": 70,
    "Port Said": 70,
    "Suez": 70,
    "Aswan": 80,
    "Asyut": 80,
    "Red Sea": 80,
    "Beni Suef": 80,
    "Faiyum": 80,
    "Qena": 80,
    "Luxor": 80,
    "Minya": 80,
    "Matrouh": 80,
    "Sohag": 80,
    "North Sinai": 90,
    "New Valley": 90,
    "South Sinai": 90,
  };

  Future<void> _fetchUserInfo() async {
    try {
      final userInfo = await AuthService.fetchUserInfo();
      print(userInfo);

      setState(() {
        _userInfo = userInfo;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          duration: const Duration(milliseconds: 500),
          backgroundColor: Colors.red,
          content: Text(
            AppLocalizations.of(context)!.pleaseLogin,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _totalAmount = _calculateTotalAmount();
    _couponCode = '';
    _fetchUserInfo();
  }

  double _calculateTotalAmount() {
    final cartItems = Provider.of<Cart>(context, listen: false).items;
    return cartItems.fold(0, (sum, item) {
      final variationPrice = int.tryParse(item.variation?.price ?? '') ?? item.product.price ?? 0;
      return sum + (variationPrice * item.quantity);
    });
  }

  Future<void> _validateCoupon() async {
    print(_couponCode);
    WooCommerceService wooCommerceService = WooCommerceService();
    final discount = await wooCommerceService.validateCoupon(_couponCode, context);
    // print(discount);
    if (discount != null) {
      setState(() {
        _discountAmount = discount[0];
        if (discount[1] == 'percent') {
          _discountAmount = _discountAmount / 100 * _totalAmount;
        } else {
          _discountAmount = discount[0];
        }
        _totalAmount = _calculateTotalAmount() - _discountAmount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coupon applied: $_discountAmount EGP discount')),
      );
    } else {
      setState(() {
        _discountAmount = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid coupon code')),
      );
    }
  }

  void _startPayTabsPayment() {
    var billingDetails = BillingDetails(
      _firstName + ' ' + _lastName,
      _email,
      _phone,
      _address,
      'SA',
      _city,
      _state,
      '11411',
    );

    var shippingDetails = ShippingDetails(
      _firstName + ' ' + _lastName,
      _email,
      _phone,
      _address,
      'EG',
      _city,
      _state,
      '11411',
    );

    var configuration = PaymentSdkConfigurationDetails(
      profileId: profileId,
      serverKey: serverKey,
      clientKey: clientKey,
      cartId: "cart_id",
      cartDescription: "Purchase from Gomla",
      merchantName: "Mskra",
      screentTitle: "Pay with Card",
      billingDetails: billingDetails,
      shippingDetails: shippingDetails,
      locale: PaymentSdkLocale.EN,
      amount: _totalAmount + _shippingCost,
      currencyCode: "EGP",
      merchantCountryCode: "EG",
    );

    FlutterPaytabsBridge.startCardPayment(configuration, (event) async {
      setState(() {
        if (event["status"] == "success") {
          var transactionDetails = event["data"];
          if (transactionDetails["isSuccess"]) {
            _submitOrder(context, Provider.of<Cart>(context, listen: false), true); // Mark order as paid
          } else {
            print(transactionDetails['message']);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(transactionDetails['paymentResult']['responseMessage'])),
            );
          }
        } else if (event["status"] == "error") {
          print("error occurred");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ')),
          );
          print(event);
        } else if (event["status"] == "event") {
          print(event);
          print("transaction cancelled");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ')),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    _totalAmount = _calculateTotalAmount();

    return Scaffold(
      appBar: CustomPagesAppBar(title: AppLocalizations.of(context)!.checkout,home: false,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "الفوترة والشحن",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.firstName} *'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _firstName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.lastName} *'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _lastName = value!,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.country} *'),
                value: _country,
                items: ['Egypt', 'Saudi Arabia'].map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _country = value!;
                    if (_country == 'Saudi Arabia') {
                      _shippingCost = 95;
                      _paymentMethod = 'cod';
                    } else {
                      _city = '';
                      _shippingCost = 0;
                    }
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              if (_country == 'Egypt')
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.city} *'),
                  value: _city.isNotEmpty ? _city : null,
                  items: _cityShippingCosts.keys.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _city = value!;
                      _shippingCost = _cityShippingCosts[_city] ?? 0.0;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.address} *'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _address = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.state} *'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _state = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.phone} *'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _phone = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.email} *'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onSaved: (value) => _email = value!,
                initialValue: _userInfo?['email'],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.orderNotes}'),
                onSaved: (value) => _orderNotes = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'كوبون '),
                onChanged: (value) {
                  setState(() {
                    _couponCode = value;
                  });
                },
              ),
              Container(
                height: 45,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _validateCoupon,
                    child: Text('تطبيق كوبون', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.paymentMethod,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              RadioListTile(
                title: Text(AppLocalizations.of(context)!.cod),
                value: 'cod',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                  });
                },
              ),
              // RadioListTile(
              //   title: const Text('ادفع اونلاين ببطاقتك الائتمانيه'),
              //   value: 'paytabs',
              //   groupValue: _paymentMethod,
              //   onChanged: (value) {
              //     setState(() {
              //       _paymentMethod = value.toString();
              //     });
              //   },
              // ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.shipping}: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_shippingCost.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('المجموع: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text((_totalAmount - _discountAmount).toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.total}: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text((_totalAmount + _shippingCost - _discountAmount).toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                ),
                onPressed: () {
                  if (_paymentMethod == 'paytabs') {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _startPayTabsPayment();
                    }
                  } else {
                    _submitOrder(context, cart, false); // By default, order is not paid
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.placeOrder,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitOrder(BuildContext context, Cart cart, bool setPaid) async {

    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_Id') ;
    print(userId);
    print(_userInfo!["data"]["id"]);

    print(" _formKey.currentState!.validate()");
    _formKey.currentState!.save();

    WooCommerceService wooCommerceService = WooCommerceService();

    bool orderCreated = await wooCommerceService.createOrder(
      firstName: _firstName,
      lastName: _lastName,
      country: _country,
      address: _address,
      city: _city,
      state: _state,
      userId: _userInfo!["data"]["id"],
      phone: _phone,
      email: _email,
      orderNotes: _orderNotes,
      couponCode: _couponCode,
      paymentMethod: _paymentMethod,
      cartItems: cart.items,
      setPaid: setPaid,
      context: context,
      shippingCost: _shippingCost.toString(),
    );

    if (orderCreated) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(index: 0)));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully')),
      );

      cart.clear();
    } else {
      print('Failed to place order');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order')),
      );
    }
  }
}
