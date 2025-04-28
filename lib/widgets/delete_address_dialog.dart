import 'dart:convert';
import 'package:Gomla/screens/main_screen.dart';
import 'package:Gomla/shared/components/toast_component.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> deleteAddress(BuildContext context, int addressId) async {
  final String url = 'https://gomla.sa/wp-json/multi-shipping/v1/addresses/$addressId';

  // Confirm deletion before making the request
  bool confirmDelete = await _showDeleteConfirmationDialog(context);
  final prefs = await SharedPreferences.getInstance();
   String? token = prefs.getString('auth_token');
  if (confirmDelete) {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'gomlaauth': 'Bearer $token', // Replace with your token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Navigator.pushAndRemoveUntil(context,   MaterialPageRoute(builder: (context) => MainScreen(index: 0)), (_) => false);

        showToast(text: data['message'], state: ToastStates.SUCCESS);

      } else {
        // Error deleting address
        final errorResponse = jsonDecode(response.body);

        showToast(text: errorResponse['message'], state: ToastStates.ERROR);
      }
    } catch (e) {

      showToast(text: e.toString(), state: ToastStates.ERROR);
    }
  }
}

Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete_address),
        content: Text(AppLocalizations.of(context)!.are_you_sure_you_want_to_delete_this_address),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false for cancel
            },
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true for confirm
            },
            child: Text(AppLocalizations.of(context)!.delete_address, style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  ) ??
      false; // Return false if dialog is dismissed
}
