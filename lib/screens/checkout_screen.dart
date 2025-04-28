import 'dart:convert';

import 'package:Gomla/screens/main_screen.dart';
import 'package:Gomla/screens/payment_screen.dart';
import 'package:Gomla/shared/components/toast_component.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkLocale.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis/admob/v1.dart';

import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../contstants.dart';
import '../env.dart';
import '../main.dart';
import '../models/adress_model.dart';
import '../models/cart.dart';
import '../models/shppong_zone_model.dart';
import '../services/auth_service.dart';
import '../services/woocommerce_service.dart';
import '../shared/global/app_theme.dart';
import '../widgets/app_bar.dart';
import 'add_new_adress_screen.dart';
import 'edit_address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double updatedTotal;

  const CheckoutScreen({super.key, required this.updatedTotal});


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
  double includedTax = 0.0;
  double _shippigTax = 20.0;

  bool isEmailEmpty = false; // Flag to check if email is empty
  @override
  void initState() {
    super.initState();
    generateLoginLink();
    _loadAddresses();
    _totalAmount = widget.updatedTotal; // Use the passed updated total
print("totalAmount: $_totalAmount");
     _fetchUserInfo();
  }

  List<Address> _addresses = []; // Store addresses

  List<ShippingZoneModel> zones = [];
  ShippingZoneModel? selectedZone;
  bool isLoading = true;

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
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7, // height 70% screen initially
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_addresses.isEmpty)
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
                              Navigator.pop(context);
                              _showAddAddressScreen();
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
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(), // Important
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
                                            AppLocalizations.of(context)!
                                                .add_new_address,
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.pop(
                                            context); // Close the bottom sheet
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
                                      if (address.state == "الرياض") {
                                        _shippingCost = 18 + (18 * .15);
                                        print(_shippingCost);
                                      } else {
                                        _shippingCost = 25 + (25 * .15);
                                        print(_shippingCost);
                                      }
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
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(Icons.map_outlined,
                                              color: Colors.black),

                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Divider(thickness: .5),
                                          Row(
                                            children: [

                                              Text(
                                                "${AppLocalizations.of(context)!.type_of_address}:  ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),

                                              Text(
                                                address.notes ,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          if (address.firstName.isNotEmpty && address.lastName.isNotEmpty)
                                            Row(
                                              children: [

                                                Text(
                                                  "${AppLocalizations.of(context)!.userName}:  ",
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
                                                "${AppLocalizations.of(context)!.address}:  ",
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
                                          if (address.phone.isNotEmpty)
                                            Row(
                                              children: [
                                                Text(
                                                  "${AppLocalizations.of(context)!.phoneNumber}:  ",
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
                ),
              ),
            );
          },
        );
      },

    );
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
      showToast(
          text: AppLocalizations.of(context)!.pleaseLogin,
          state: ToastStates.ERROR);
    }
  }

  void _showAddAddressScreen() {
    // Example: Navigate to the screen where the user can add a new address
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
            address: "",
            city: "",
            state: "",
            country: "",
            postcode: ""), // Replace with your Add Address screen
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
  String? loginUrl;
  final TextEditingController _emailController = TextEditingController();
  bool _isAddressSelected = false;

  Future<void> generateLoginLink() async {
    final String apiUrl = 'https://gomla.sa/wp-json/custom-auth/v1/generate-login-link'; // Replace with your actual URL
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      // Make the POST request with the required headers
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'gomlaauth': "Bearer $token", // Use Bearer token for authorization
          'Content-Type': 'application/json', // Assuming JSON body type
        },
        body: json.encode({}), // Assuming no additional body data
      );

      if (response.statusCode == 200) {
        // If the request is successful, parse the JSON response
        final responseData = json.decode(response.body);
        print("Response: $responseData");

        // Check if the response contains the 'login_url'
        if (responseData['success'] == true && responseData['login_url'] != null) {
          String generatedLoginUrl = responseData['login_url'];

          // Save the login URL in SharedPreferences (optional)
          prefs.setString('login_url', generatedLoginUrl);

          // Update the state with the generated login URL
          setState(() {
            loginUrl = generatedLoginUrl;
          });

          print('Login URL generated and saved in SharedPreferences: $loginUrl');
        } else {
          print('Error: Failed to retrieve login URL');
        }
      } else {
        final responseData = json.decode(response.body);
        print('Error: ${response.statusCode}');
        print('Error Details: ${responseData}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _submitOrder(BuildContext context, Cart cart, bool setPaid) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userId = _userInfo?["data"]["id"];
      final name = _userInfo?["data"]["name"];
      final email = isEmailEmpty ? _emailController.text : _email;

      if (_address == null || _address!.isEmpty) {
        showToast(
          text: AppLocalizations.of(context)!.pleaseEnterYourAddress,
          state: ToastStates.ERROR,
        );
        return;
      }

      if (email == null || email.isEmpty) {
        showToast(
          text: 'Please enter your email',
          state: ToastStates.ERROR,
        );
        return;
      }
      final service = WooCommerceService();
      // Call createOrder to create the order on the server
      final result = await service.createOrder(
        status: "pending",
        firstName: name,
        lastName: name ?? "",
        country: _country,
        address: _address,
        city: _city,
        state: _state,
        total: _totalAmount.toString(),
        totalPrice: _totalAmount + _shippingCost ,
        phone: _phone,
        email: email,
        orderNotes: _orderNotes,
        shippingCost: _shippingCost.toString(),
        paymentMethod: _paymentMethod,
        cartItems: cart.items,
        context: context,
        setPaid: setPaid,
        userId: userId!,
      );

      if (result.isNotEmpty) {
        // Extract the orderId and orderKey from the result
        String orderId = result['orderId']!;
        String orderKey = result['orderKey']!;

        // Navigate to the PaymentPage and pass orderId and orderKey
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              id: orderId,
              orderKey: orderKey,
            ),
          ),
        );

      } else
      {
        print("Order creation failed");
      }
    }
  }
  void _submitOrderCod(BuildContext context, Cart cart, bool setPaid) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userId = _userInfo?["data"]["id"];
      final name = _userInfo?["data"]["name"];
      final email = isEmailEmpty ? _emailController.text : _email;

      if (_address == null || _address!.isEmpty) {
        showToast(
          text: AppLocalizations.of(context)!.pleaseEnterYourAddress,
          state: ToastStates.ERROR,
        );
        return;
      }

      if (email == null || email.isEmpty) {
        showToast(
          text: 'Please enter your email',
          state: ToastStates.ERROR,
        );
        return;
      }
      final service = WooCommerceService();
      // Call createOrder to create the order on the server
      final result = await service.createOrder(
        firstName: name,
        lastName: name ?? "",
        country: _country,
        address: _address,
        city: _city,
        state: _state,
        total: _totalAmount.toString(),
        totalPrice: _totalAmount + _shippingCost ,
        phone: _phone,
        email: email,
        orderNotes: _orderNotes,
        shippingCost: _shippingCost.toString(),
        paymentMethod: _paymentMethod,
        cartItems: cart.items,
        context: context,
        setPaid: setPaid,
        userId: userId!,
        status: "processing"
      );
if (result.isEmpty) {
      print("Order creation failed");
    }
      print("✅ Order created successfully");
      cart.clear();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen(index: 0)));
      showToast(text: AppLocalizations.of(context)!.order_placed_successfully, state: ToastStates.SUCCESS);
    }
  }

  bool isSelectedZone = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    double totalCost = _totalAmount + _shippingCost + _shippigTax;
double _includedTax = _paymentMethod == "cod" ? (  (_totalAmount*0.15) +( _shippingCost * 0.15)+2.61 ) :(  (_totalAmount*0.15) +( _shippingCost * 0.15)  );
print(_includedTax);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomPagesAppBar(
          title: AppLocalizations.of(context)!.checkout, home: false),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              loginUrl != null
                  ? Container(
                width: 0,
                height: 0,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(loginUrl!)), // Use the login URL here
                  onWebViewCreated: (controller) {
                   },
                  onLoadStart: (controller, url) {
                    print("Started loading: $url");
                  },
                  onLoadStop: (controller, url) {
                    print("Stopped loading: $url");
                  },
                ),
              )
                  : Container(),
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

                  // Check if the item is taxable and calculate the price accordingly
                  double price = item.product.price;
                  double regularPrice = item.product.regularPrice;

                  // Apply tax if shipping is taxable
                  if (item.product.shipping_taxable == true) {
                    price += price * 0.15;
                    regularPrice += regularPrice * 0.15;
                  }

                  return Card(
                    color: Colors.white,
                    elevation: .01,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                  child: item.product.images.isNotEmpty
                                      ? Image.network(
                                          item.product.images.first,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.contain,
                                        )
                                      : Image.asset(
                                          'assets/placeholder.png', // Use a default placeholder image
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text('${price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                          const SizedBox(width: 4),
                                          SvgPicture.asset("assets/SAR.svg",
                                            width: 16, height: 16,color: Colors.black,),
                                          Spacer(),
                                          item.product.shipping_taxable == true
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(0.0),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(height: 3),
                                                      Text(
                                                        '${AppLocalizations.of(context)!.incl_vat}',
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : const Text(''),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // if variation attributes has color return container

                                      Text(
                                        '${AppLocalizations.of(context)!.quantity}: ${item.quantity}',
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                    border: Border.all(
                        color: !_address.isEmpty ? Colors.grey : Colors.red),
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
                            ? Icon(
                                Icons.email_outlined,
                                size: 20,
                                color: Color(0xFFDC9D1E),
                              ) // Prefix for Arabic
                            : Directionality(
                                textDirection: TextDirection.ltr,
                                child: Icon(
                                  Icons.email_outlined,
                                  size: 20,
                                  color: Color(0xFFDC9D1E),
                                ),
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
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value.toString();
                    _shippigTax = 20;
                    print(_paymentMethod);
                  });},
              ),
              RadioListTile(
                title: Text(AppLocalizations.of(context)!.creditCard),
                activeColor: mainColor,
                value: 'Credit Card',
                groupValue: _paymentMethod,
                onChanged: (value) {
                    setState(() {
                       _paymentMethod = value.toString();
                       _shippigTax = 0;
                       print(_paymentMethod);
                    });},
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.total} : ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Spacer(flex: 1),
                  Text(
                    '${_totalAmount.toStringAsFixed(2)} ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ), SizedBox(width: 5),
                  SvgPicture.asset("assets/SAR.svg", width: 16, height: 16,color: Colors.black,), SizedBox(width: 5),
                  Text('${AppLocalizations.of(context)!.incl_vat} ',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 10),
              if (_shippingCost != 0.0)
                Row(
                  children: [
                    Text('${AppLocalizations.of(context)!.shipping} : ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Spacer(flex: 1),
                    Text(' ${_shippingCost}', // or show more methods
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)), SizedBox(width: 5),
                    SvgPicture.asset("assets/SAR.svg", width: 16, height: 16,color: Colors.black,), SizedBox(width: 5),
                    Text('${AppLocalizations.of(context)!.incl_vat} ',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              SizedBox(height: 10),
              if (_shippigTax != 0.0)
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.shippingTax} : ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Spacer(flex: 1),
                  Text(
                    ' ${_shippigTax}', // or show more methods
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ), SizedBox(width: 5),
                  SvgPicture.asset("assets/SAR.svg", width: 16, height: 16,color: Colors.black,),
                  SizedBox(width: 5),
                  Text('${AppLocalizations.of(context)!.incl_vat} ',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text('${AppLocalizations.of(context)!.totalAmount} : ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Spacer(flex: 1),
                  Text(
                    '${totalCost.toStringAsFixed(2)} ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ), SizedBox(width: 5),
                  SvgPicture.asset("assets/SAR.svg",width: 16, height: 16,color: Colors.black,),
                  SizedBox(width: 5),
                  Row(
                    children: [
                      Text('(${AppLocalizations.of(context)!.includes} ${_includedTax.toStringAsFixed(2)} ',
                          style:
                              TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      SvgPicture.asset("assets/SAR.svg", width: 12, height: 12 ),
                      Text(' ${AppLocalizations.of(context)!.tax})',
                          style:
                              TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
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
                  minimumSize: Size(mediaQueryWidth(context) * .9, 40),
                  backgroundColor:
                      Color(0xFF212224), // <--- Change color if disabled
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_paymentMethod == 'paytabs') {
                      _formKey.currentState!.save();
                      _startPayTabsPayment();
                    } else {
                      if (_paymentMethod == 'cod') {
                        _submitOrderCod(context, cart, false)    ;
                      }else{
                        _submitOrder(context, cart, false);

                      }
                    }
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.placeOrder,
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
