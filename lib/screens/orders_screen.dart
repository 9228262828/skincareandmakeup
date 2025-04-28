import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/order.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../widgets/app_bar.dart';
import '../widgets/fade_image.dart';
import 'package:shimmer/shimmer.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = fetchAllOrders(context);
    setupTimeAgoLocalization();
  }

  Future<List<Order>> fetchOrdersForLocale(String locale, BuildContext context) async {
    final String consumerKey = 'ck_1c63c710561ce560194698e6f676fe67ee2ed927';
    final String consumerSecret = 'cs_a8ba1ef8b549189d415618ba993a4a0c6f2f7166';

    try {
      final pref = await SharedPreferences.getInstance();
      final String jwtToken = pref.getString('auth_token') ?? '';

      final userInfo = await AuthService.fetchUserInfo();
      final userId = userInfo["data"]['id'];

      String auth = 'Basic ' + base64Encode(utf8.encode('$consumerKey:$consumerSecret'));

      final response = await http.get(
        Uri.parse('https://gomla.sa/wp-json/wc/v3/orders?customer=$userId&lang=$locale'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
          'gomlaauth': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is List) {
          return jsonResponse.map((order) => Order.fromJson(order)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Order>> fetchAllOrders(BuildContext context) async {
    final ordersInArabic = await fetchOrdersForLocale('ar', context);
    final ordersInEnglish = await fetchOrdersForLocale('en', context);

    final allOrders = [...ordersInArabic, ...ordersInEnglish];

    allOrders.sort((a, b) {
      DateTime aDate = DateTime.parse(a.dateCreated);
      DateTime bDate = DateTime.parse(b.dateCreated);
      return bDate.compareTo(aDate); // Newest first
    });

    return allOrders;
  }

  void setupTimeAgoLocalization() {
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: CustomPagesAppBar(title: AppLocalizations.of(context)!.myOrders, home: false),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerGrid(context);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noOrdersFound));
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final order = snapshot.data![index];
                  return OrderCard(order: order);
                },
              ),
            );
          }
        },
      ),
    );
  }

  // Shimmer grid when orders are loading
  Widget _buildShimmerGrid(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Number of shimmer items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final lineItem = order.lineItems.isNotEmpty ? order.lineItems[0] : null;
    String? locale = Localizations.localeOf(context).languageCode;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.orderId,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    order.id.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Product Image and Title
            if (lineItem != null) ...[
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      lineItem.image,
                      width: 40,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lineItem.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context)!.quantity} : ${lineItem.quantity}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.status == "processing"
                                  ? AppLocalizations.of(context)!
                                  .orderProcessing
                                  : AppLocalizations.of(context)!
                                  .orderCancelled,
                              style: TextStyle(
                                color: order.status == "processing"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              timeago.format(
                                DateTime.parse(order.dateCreated.toString()),
                                locale: locale,
                              ) ?? ' ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            // Total Price Section
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.total} : ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(flex: 1),
                  Text(
                    '${order.total} ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/SAR.svg",
                    width: 16,
                    height: 16,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
