import 'package:Gomla/main.dart';
import 'package:Gomla/screens/reset_pass_screen.dart';
import 'package:Gomla/shared/components/toast_component.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';
class DeleteAccount extends StatelessWidget {
  const DeleteAccount({super.key});
  void deleteAccount(context) {
    // Delete account
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey.shade100,
          title: Text(AppLocalizations.of(context)!.deleteAccount),
          content: Text(AppLocalizations.of(context)!.deleteAccountWarning),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.deleteAccount,
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                deleteAccountServer(context);
                Navigator.of(context).pop();
              },
            )
          ],
        ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade100,
          title: Text(AppLocalizations.of(context)!.securitySettings),
        ),
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  deleteAccount(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: mediaQueryHeight(context) * 0.135,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.deleteAccount,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18)),
                        SizedBox(height: mediaQueryHeight(context) * 0.01),
                        Text(AppLocalizations.of(context)!.deleteAccountWarning,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                        SizedBox(height: mediaQueryHeight(context) * 0.01),
                        Text(AppLocalizations.of(context)!.deleteMyAccount,
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPassScreen()));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: mediaQueryHeight(context) * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.forgetPassword,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18)),
                        SizedBox(height: mediaQueryHeight(context) * 0.01),

                        Text(AppLocalizations.of(context)!.resetPassword,
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }



  Future<void> deleteAccountServer(context) async {
    String _tokenKey = 'auth_token';
    String _userIdKey = 'user_id';

    final String url = "https://gomla.egymetrix.net/wp-json/custom-auth/v1/delete-account";
    var prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString(_tokenKey);
    int? userId = prefs.getInt(_userIdKey);

    print("Token: $token");
    print("User ID: $userId");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'gomlaauth': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "user_id": userId,
        }),
      );

      final responseData = json.decode(response.body);
      print("Response: $responseData");

      if (response.statusCode == 200 && responseData["success"] == true) {
        print("Account deleted successfully!");
        showToast(text: responseData['message'], state: ToastStates.SUCCESS);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>   MainScreen(index: 0)));

        // Clear token and user ID from SharedPreferences
        await prefs.remove(_tokenKey);
        await prefs.remove(_userIdKey);
        await prefs.setBool(  "isLoggedIn", false);

        print("User credentials cleared from storage.");
      } else {
        print("Failed to delete account: ${responseData['message'] ?? 'Unknown error'}");
        showToast(text: responseData['message'], state: ToastStates.ERROR);
      }
    } catch (e) {
      print("Error deleting account: $e");
    }
  }



}
