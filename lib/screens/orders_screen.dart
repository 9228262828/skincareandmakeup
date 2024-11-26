import 'package:flutter/material.dart';
import 'package:skincare/widgets/app_bar.dart';
import 'package:skincare/widgets/fade_image.dart';
import 'package:provider/provider.dart';
import '../services/woocommerce_service.dart';
import '../models/order.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = WooCommerceService().fetchUserOrders(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'My Orders'),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return FadeInOutImage(height: MediaQuery.of(context).size.height);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noOrdersFound));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return ListTile(
                  title: Text(AppLocalizations.of(context)!.order + ' #${order.id}'),
                  subtitle: Text('${AppLocalizations.of(context)!.status}: ${order.status}'),
                  trailing: Text('${AppLocalizations.of(context)!.total}: ${order.total}'),
                  onTap: () {
                    // Navigate to order details if needed
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
