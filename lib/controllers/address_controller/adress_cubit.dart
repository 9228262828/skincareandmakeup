import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Gomla/models/adress_model.dart'; // Import your Address model
 import 'package:Gomla/shared/components/toast_component.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'address_states.dart';


class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(AddressInitial());

  Future<void> fetchAddresses() async {
    emit(AddressLoading());

    String _tokenKey = 'auth_token';
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    try {
      final response = await http.get(
        Uri.parse('https://gomla.sa/wp-json/multi-shipping/v1/addresses'),
        headers: {
          "gomlaauth": 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          List<Address> addresses = data.map((address) => Address.fromJson(address)).toList();
          emit(AddressLoaded(addresses: addresses));
        } else {
          emit(AddressError(message: "Invalid response structure"));
        }
      } else {
        emit(AddressError(message: "Failed to fetch addresses"));
      }
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }

  Future<void> deleteAddress(BuildContext context, int addressId) async {
    final String url = 'https://gomla.sa/wp-json/multi-shipping/v1/addresses/$addressId';

    bool confirmDelete = await _showDeleteConfirmationDialog(context);
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (confirmDelete) {
      try {
        final response = await http.delete(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'gomlaauth': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          emit(AddressDeleted());
          showToast(text: data['message'], state: ToastStates.SUCCESS);
        } else {
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:  Colors.white,
          title: Text(AppLocalizations.of(context)!.delete_address),
          content: Text(AppLocalizations.of(context)!.are_you_sure_you_want_to_delete_this_address),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.delete_address, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}