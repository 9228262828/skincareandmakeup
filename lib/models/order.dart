class Order {
  final int id;
  final String status;
  final String currency;
  final String total;
  final String dateCreated;
  final String dateModified;
  final Billing billing;
  final Shipping shipping;
  final List<LineItem> lineItems;
  final String paymentMethod;
  final String paymentMethodTitle;
  final String paymentUrl;

  Order({
    required this.id,
    required this.status,
    required this.currency,
    required this.total,
    required this.dateCreated,
    required this.dateModified,
    required this.billing,
    required this.shipping,
    required this.lineItems,
    required this.paymentMethod,
    required this.paymentMethodTitle,
    required this.paymentUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      currency: json['currency'],
      total: json['total'],
      dateCreated: json['date_created'],
      dateModified: json['date_modified'],
      billing: Billing.fromJson(json['billing']),
      shipping: Shipping.fromJson(json['shipping']),
      lineItems: (json['line_items'] as List)
          .map((item) => LineItem.fromJson(item))
          .toList(),
      paymentMethod: json['payment_method'],
      paymentMethodTitle: json['payment_method_title'],
      paymentUrl: json['payment_url'],
    );
  }
}

class Billing {
  final String firstName;
  final String lastName;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final String email;
  final String phone;

  Billing({
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
    required this.email,
    required this.phone,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      firstName: json['first_name'],
      lastName: json['last_name'],
      address1: json['address_1'],
      address2: json['address_2'],
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class Shipping {
  final String firstName;
  final String lastName;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final String phone;

  Shipping({
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
    required this.phone,
  });

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      firstName: json['first_name'],
      lastName: json['last_name'],
      address1: json['address_1'],
      address2: json['address_2'],
      city: json['city'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
      phone: json['phone'],
    );
  }
}

class LineItem {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final String sku;
  final String image;

  LineItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.sku,
    required this.image,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      sku: json['sku'],
      image: json['image']['src'],
    );
  }
}
