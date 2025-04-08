import 'dart:convert';

import 'package:Gomla/screens/main_screen.dart';
import 'package:Gomla/shared/components/toast_component.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkLocale.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:googleapis/admob/v1.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../contstants.dart';
import '../env.dart';
import '../main.dart';
import '../models/adress_model.dart';
import '../models/cart.dart';
import '../services/auth_service.dart';
import '../services/woocommerce_service.dart';
import '../shared/global/app_theme.dart';
import '../widgets/app_bar.dart';
import 'add_new_adress_screen.dart';
import 'edit_address_scree.dart';

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
  double _shippingCost = 0.0;
  double _discountAmount = 0.0;
  bool _isLoading = false;

  bool isEmailEmpty = false; // Flag to check if email is empty
  @override
  void initState() {
    super.initState();
     _loadAddresses();

    _totalAmount = _calculateTotalAmount();
    _fetchUserInfo();



  }
  List<Address> _addresses = []; // Store addresses





  Future<void> _loadAddresses() async {
    List<Address> addresses = await _fetchAddresses();
    setState(() {
      _addresses = addresses;
    });
  }

  Future<List<Address>> _fetchAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final response = await http.get(
      Uri.parse('https://gomla.sa/wp-json/multi-shipping/v1/addresses'),
      headers: {"gomlaauth": 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.map<Address>((e) => Address.fromJson(e)).toList();
    }
    return []; // Return an empty list if fetching fails
  }

  Future<void> _showAddressPickerBottomSheet() async {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            if (_addresses.isEmpty)
            // If the addresses list is empty, show the "Add Address" button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF212224),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _showAddAddressScreen(); // Show the Add Address screen or form
                    },
                    child: Text(AppLocalizations.of(context)!.add_new_address),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppLocalizations.of(context)!.choose_address,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true, // Ensures the list takes up only the required space
                    itemCount: _addresses.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _addresses.length) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Color(0xFF212224),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Color(0xFFEAEAEA),
                                width: 1.0,
                              ),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: Colors.white),
                                  Text(
                                    AppLocalizations.of(context)!.add_new_address,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context); // Close the bottom sheet
                                _showAddAddressScreen(); // Show the Add Address screen or form
                              },
                            ),
                          ),
                        );
                      }
                      final address = _addresses[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _firstName = address.firstName;
                              _lastName = address.lastName;
                              _address = address.address1;
                              _city = address.city;
                              _state = address.state;
                              _phone = address.phone;
                            });
                            Navigator.pop(context);
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Color(0xFFEAEAEA),
                                width: 1.0,
                              ),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.map_outlined, color: Colors.black),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditAddressScreen(address: address),
                                        ),
                                      ).then((_) {
                                        _loadAddresses(); // Refresh addresses after editing
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.edit_address,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(thickness: .5),
                                  Row(
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.userName}:   ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        address.firstName + " " + address.lastName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.address}:   ",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          address.address1,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        "${AppLocalizations.of(context)!.userName}:   ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        address.phone,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  double _calculateTotalAmount() {
    final cartItems = Provider.of<Cart>(context, listen: false).items;
    return cartItems.fold(0, (sum, item) {
      final price =
          int.tryParse(item.variation?.price ?? '') ?? item.product.price ?? 0;
      return sum + (price * item.quantity);
    });
  }

  Future<void> _fetchUserInfo() async {
    try {
      final userInfo = await AuthService.fetchUserInfo();
      setState(() => _userInfo = userInfo);
      print(_userInfo);
      _email = _userInfo?["data"]["email"];
      if (_email == null || _email.isEmpty) {
        isEmailEmpty = true;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.pleaseLogin),
        backgroundColor: Colors.red,
      ));
    }
  }



  void _showAddAddressScreen() {
    // Example: Navigate to the screen where the user can add a new address
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(address: "", city: "", state: "", country: "", postcode: ""), // Replace with your Add Address screen
      ),
    );
  }

  void _startPayTabsPayment() {
    final billing = BillingDetails("$_firstName $_lastName", _email, _phone,
        _address, 'SAR', _city, _state, '11411');
    final shipping = ShippingDetails("$_firstName $_lastName", _email, _phone,
        _address, 'SAR', _city, _state, '11411');
    final config = PaymentSdkConfigurationDetails(
      profileId: profileId,
      serverKey: serverKey,
      clientKey: clientKey,
      cartId: "cart_id",
      cartDescription: "Purchase from Gomla",
      merchantName: "Gomla",
      screentTitle: "Pay with Card",
      billingDetails: billing,
      shippingDetails: shipping,
      locale: PaymentSdkLocale.EN,
      amount: _totalAmount + _shippingCost,
      currencyCode: "SAR",
      merchantCountryCode: "SA",
    );
    FlutterPaytabsBridge.startCardPayment(config, (event) {
      if (event["status"] == "success" && event["data"]["isSuccess"] == true) {
        _submitOrder(context, Provider.of<Cart>(context, listen: false), true);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Payment error')));
      }
    });
  }
  final TextEditingController _emailController = TextEditingController();

  void _submitOrder(BuildContext context, Cart cart, bool setPaid) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userId = _userInfo?["data"]["id"];
      final name = _userInfo?["data"]["name"];
      final email = isEmailEmpty ? _emailController.text : _email;
      if (_address == null || _address!.isEmpty) {
        setState(() {
          _isAddressSelected = false; // Mark the address as not selected
        });
        showToast(text: 'Please select a delivery address', state: ToastStates.ERROR);
        return; // Prevent order submission
      } else {
        setState(() {
          _isAddressSelected = true; // Mark the address as selected
        });
      }
      if (email == null || email.isEmpty) {
        // Show error message if email is still missing
        showToast(text: 'Please enter your email', state: ToastStates.ERROR);
        return;
      }

      print("---- Order Info ----");
      print("First Name: $name");
      print("Last Name: $name");
      print("Country: $_country");
      print("Address: $_address");
      print("City: $_city");
      print("State: $_state");
      print("Phone: $_phone");
      print("Email: $email");
      print("Order Notes: $_orderNotes");
      print("Coupon Code: $_shippingCost");
      print("Payment Method: $_paymentMethod");
      print("Shipping Cost: $_shippingCost");
      print("Set Paid: $setPaid");
      print("User ID: $userId");

      print("Cart Items:");
      for (var item in cart.items) {
        print(" - Product: ${item.product.name}, Quantity: ${item.quantity}, Price: ${item.product.price}, Variation: ${item.variation?.price}");
      }

      final service = WooCommerceService();
      final success = await service.createOrder(
        firstName: name,
        lastName: name ?? "",
        country: _country,
        address: _address,
        city: _city,
        state: _state,
        userId: userId,
        phone: _phone,
        email: email, // Use the email provided
        orderNotes: _orderNotes,
        couponCode: "",
        paymentMethod: _paymentMethod,
        cartItems: cart.items,
        setPaid: setPaid,
        context: context,
        shippingCost: _shippingCost.toString(),
      );

      if (success) {
        print("✅  ");
        cart.clear();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen(index: 0)));
        showToast(text: AppLocalizations.of(context)!.order_placed_successfully, state: ToastStates.SUCCESS);
      } else {
        print(" ");
       }
    }
  }

  bool _isAddressSelected = false; // Flag to track if the address is selected

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    _totalAmount = _calculateTotalAmount();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomPagesAppBar(
          title: AppLocalizations.of(context)!.checkout, home: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 🛒 عرض المنتجات في السلة
              Text(
                "${AppLocalizations.of(context)!.your_order}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ListView.builder(
                shrinkWrap: true, // لكي لا يقوم بتوسيع حجم الـ ListView
                physics:
                NeverScrollableScrollPhysics(), // منع التمرير داخل هذه القائمة
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Color(0xFFEAEAEA))),
                    elevation: 0,
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(item.product.name),
                      subtitle: Text(
                          "Price: ${item.product.price} EGP\nQuantity: ${item.quantity}"),
                      trailing:
                      Text("${item.product.price * item.quantity} EGP"),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 🏠 عرض العنوان
              Text("${AppLocalizations.of(context)!.billingAddress}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _showAddressPickerBottomSheet,
                child: Container(

                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: !_address.isEmpty ? Colors.grey : Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: mainColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _address.isEmpty
                              ? '${AppLocalizations.of(context)!.chooseDeliveryAddress}'
                              : '$_address، $_city، $_state',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              if (isEmailEmpty)
                TextFormField(
                  controller: _emailController,
                  decoration: customInputDecoration(
                    prefixIcon:
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? Icon(Icons.email_outlined,
                      size: 20,color:   Color(0xFFDC9D1E),) // Prefix for Arabic
                        : Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(Icons.email_outlined, size: 20, color:  Color(0xFFDC9D1E),),
                    ),
                    context,
                    "${AppLocalizations.of(context)!.email}  ",
                    "${AppLocalizations.of(context)!.email}  ",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emailRequired;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
              // 💳 طرق الدفع
              RadioListTile(
                title: Text(AppLocalizations.of(context)!.cod),
                activeColor: mainColor,
                value: 'cod',
                groupValue: _paymentMethod,
                onChanged: (value) =>
                    setState(() => _paymentMethod = value.toString()),
              ),
              const SizedBox(height: 20),

              // 🚚 الشحن
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.shipping}: ',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('$_shippingCost', style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.total}: ',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_totalAmount + _shippingCost - _discountAmount}',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 20),

              // 🔲 زر لتأكيد الطلب
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    maximumSize: Size(double.infinity, 50),
                    fixedSize: Size(double.infinity, 45),
                    minimumSize:
                    Size(mediaQueryWidth(context) * .9, 40),
                    backgroundColor: Color(0xFF212224),
                    foregroundColor: Colors.white,
                    elevation: 0),

                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_paymentMethod == 'paytabs') {
                      _formKey.currentState!.save();
                      _startPayTabsPayment();
                    } else {
                      _submitOrder(context, cart, false);
                    }
                  }
                },
                child: Text(AppLocalizations.of(context)!.placeOrder,
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
