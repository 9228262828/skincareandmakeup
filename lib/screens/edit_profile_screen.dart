import 'dart:convert';
import 'package:Gomla/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart'; // Make sure the AuthService class is imported
import '../shared/components/toast_component.dart';
import '../shared/global/app_theme.dart';
import '../shared/utils/app_values.dart';
import 'main_screen.dart'; // Import your MainScreen

class EditProfileScreen extends StatefulWidget {
  Map<String, dynamic>? userInfo;

  EditProfileScreen({
    required this.userInfo
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.userInfo!['data']['first_name']);
    lastNameController = TextEditingController(text: widget.userInfo!['data']['last_name']);
    emailController = TextEditingController(text: widget.userInfo!['data']['email']);
    print(widget.userInfo);
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
  }

  // Function to update the profile
  void updateProfile(String firstName, String lastName, String email) async {
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      // Show an error message if any field is empty
      print("Error: All fields must be filled.");
      return;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      print("Error: Invalid email address.");
      return;
    }

    try {
      // Call your API or backend service to update the user's profile
      final response = await AuthService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      if (response['success']) {
        print("Profile updated successfully");

        // Show success message
        showToast(text: AppLocalizations.of(context)!.profileUpdatedSuccessfully, state: ToastStates.SUCCESS);

        // Navigate to the main screen after success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(index: 3,)),
        );
      } else {
        print("Error updating profile: ${response['error']}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CustomPagesAppBar(title: AppLocalizations.of(context)!.updateProfile , home:false ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 40,
                child: Text("${widget.userInfo !["data"]['first_name']?[0]}"  "${widget.userInfo !["data"]['last_name']?[0]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: widget.userInfo !["data"]['name'] ?? 'Guest User',
              readOnly: true,
              decoration: customInputDecoration(context,AppLocalizations.of(context)!.userName, AppLocalizations.of(context)!.userName,

              ),
            ),
            SizedBox(height: 16),
            TextFormField(
                initialValue: widget.userInfo !["data"]['phone'] ?? 'No Phone Available',
                readOnly: true,
                decoration: customInputDecoration(context,  AppLocalizations.of(context)!.userName, "")
            ),
            SizedBox(height: 24),
            // Email Field (Read-Only)

            SizedBox(height: 16),
             TextFormField(
              controller: firstNameController,
              decoration: customInputDecoration(context, AppLocalizations.of(context)!.firstName, AppLocalizations.of(context)!.firstName,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: lastNameController,
              decoration:  customInputDecoration(context, AppLocalizations.of(context)!.lastName,AppLocalizations.of(context)!.lastName,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration:  customInputDecoration(context, AppLocalizations.of(context)!.email, AppLocalizations.of(context)!.email,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Get the updated values from the text fields
                String updatedFirstName = firstNameController.text;
                String updatedLastName = lastNameController.text;
                String updatedEmail = emailController.text;

                // Call the update profile function
                updateProfile(updatedFirstName, updatedLastName, updatedEmail);
              },
              child: Text(AppLocalizations.of(context)!.updateProfile),style: ElevatedButton.styleFrom(
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
            ),
          ],
        ),
      ),
    );
  }

}