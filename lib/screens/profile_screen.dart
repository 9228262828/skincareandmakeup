import 'package:Gomla/Engin/skincare.dart';
import 'package:Gomla/screens/delete_account_Screen.dart';
import 'package:Gomla/screens/policy_screen.dart';
import 'package:Gomla/screens/terms_screen.dart';
import 'package:Gomla/shared/global/app_theme.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contstants.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../shared/components/toast_component.dart';
import '../widgets/account_shimmer.dart';
import '../widgets/app_bar.dart';
import '../widgets/language_selector.dart';
import '../widgets/unauth_widget.dart';
import 'edit_profile_screen.dart';
import 'fav_screen.dart';
import 'help_screen.dart';
import 'main_screen.dart';
import 'orders_screen.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final Map<String, dynamic>? userInfo;
  final String? errorMessage;

  const ProfileState({
    this.isLoading = true,
    this.userInfo,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, userInfo, errorMessage];
}

// Cubit Logic
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  Future<void> fetchUserInfo(context) async {
    try {
      emit(ProfileState(isLoading: true));

      final userInfo = await AuthService.fetchUserInfo();
      print("Fetched User Info: $userInfo"); // تحقق من البيانات المسترجعة

      emit(ProfileState(isLoading: false, userInfo: userInfo));
    } catch (e) {
      print("Error fetching user info: $e"); // طباعة أي أخطاء
      emit(ProfileState(
        isLoading: false,
        errorMessage: AppLocalizations.of(context)!.pleaseLogin,
      ));
    }
  }

  void logout() {
    AuthService.logout();
    emit(const ProfileState(isLoading: false)); // Reset after logout
  }
}

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Set the status bar to black with light icons (white)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Black status bar
      statusBarIconBrightness: Brightness.light, // White status bar icons
    ));
  }

  @override
  void dispose() {
    super.dispose();
    // Reset status bar color when leaving the screen (optional)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Reset to default (transparent)
    ));
  }

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
        showToast(text: AppLocalizations.of(context)!.profileUpdatedSuccessfully, state: ToastStates.SUCCESS);
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(index: 3,)));

      } else {
        print("Error updating profile: ${response['error']}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..fetchUserInfo(context),
      child: Scaffold(
        appBar: CustomAppBar(title: '', home: true),
        backgroundColor: Colors.grey.shade100,
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return MyShimmerScreen();
            }

            return _buildProfileScreen(context, state.userInfo);
          },
        ),
      ),
    );
  }

  Widget _buildProfileScreen(
      BuildContext context, Map<String, dynamic>? userInfo) {
    // List of items that can contain either icons or image paths
    final List<Map<String, dynamic>> gridItems = [
      {
        'text': AppLocalizations.of(context)!.orders,
        'icon': Icons.local_mall,
        'action': () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => OrdersScreen()));
        }
      },
      {
        'text': AppLocalizations.of(context)!.favorites,
        'icon': Icons.favorite_border,
        'action': () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => FavScreen()));
        }
      },
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userInfo == null) ...[
              UnauthWidget(),
            ] else ...[
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:

                        GestureDetector(
                            onTap: (){
                              Navigator.push(context,MaterialPageRoute(builder:  (context) => EditProfileScreen(
                                userInfo:   userInfo,
                              )));

                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 25,
                            child: Text(userInfo["data"]['name']?[0] ?? "G",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Text(
                                userInfo["data"]['name'] ?? 'Guest User',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                userInfo["data"]['email'] ?? 'No Email Available',
                                style:
                                TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: mediaQueryHeight(context) * 0.1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 2.1,
                  ),
                  padding: const EdgeInsets.all(0),
                  itemCount: gridItems.length,
                  // Number of items in the grid
                  itemBuilder: (context, index) {
                    var item = gridItems[index];

                    // Check if the icon is an IconData or a String (image path)
                    return GestureDetector(
                      onTap: item['action'],
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Display Icon or Image depending on the data type
                              item['icon'] is IconData
                                  ? Icon(
                                      item['icon'] as IconData,
                                      color: Colors.grey.shade500,
                                      size: 35,
                                    )
                                  : Image.asset(
                                      item['icon'] as String,
                                      height: 40,
                                      width: 40,
                                    ),
                              SizedBox(width: 10),
                              Text(
                                item['text']!,
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: mediaQueryHeight(context) * 0.02,
              ),
              Text(
                AppLocalizations.of(context)!.settings,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: mediaQueryHeight(context) * 0.02),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: _buildLanguageSelector(context)),
              SizedBox(height: mediaQueryHeight(context) * 0.01),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: _buildDeleteAccount(context)),
              SizedBox(height: mediaQueryHeight(context) * 0.01),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: _buildShareApp(context)),
              SizedBox(height: mediaQueryHeight(context) * 0.01),
              GestureDetector(
                onTap: () {
                  context.read<ProfileCubit>().logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainScreen(index: 0)),
                  );
                },
                child: Container(
                  height: mediaQueryHeight(context) * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(AppLocalizations.of(context)!.logout,
                            style: TextStyle(
                              color: mainColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w100,
                            )),
                        Spacer(flex: 1),
                        Icon(
                          Icons.logout,
                          color: mainColor,
                          size: 25,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: mediaQueryHeight(context) * 0.02),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.getString("locale");
                                print("Locale: ${prefs.getString("locale")}");

                                prefs.getString("locale") == "ar"
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivacyPolicyScreen(
                                                  url:
                                                      'https://gomla.sa/shipping-policy-app-ar/',
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .shipping_policies_and_pricing,
                                                )),
                                      )
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivacyPolicyScreen(
                                                  url:
                                                      "https://gomla.sa/en/shipping-policies-and-rates-app-en/",
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .shipping_policies_and_pricing,
                                                )),
                                      );
                              },
                              child: Text(
                                AppLocalizations.of(context)!
                                    .shipping_policies_and_pricing,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade500),
                              )),
                          SizedBox(
                            height: 7,
                          ),
                          GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.getString("locale");
                                print("Locale: ${prefs.getString("locale")}");

                                prefs.getString("locale") == "ar"
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivacyPolicyScreen(
                                                  url:
                                                      'https://gomla.sa/privacy-policy-app-ar/',
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .privacyPolicy,
                                                )),
                                      )
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivacyPolicyScreen(
                                                  url:
                                                      "https://gomla.sa/en/privacy-policy-app-en/",
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .privacyPolicy,
                                                )),
                                      );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.privacyPolicy,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade500),
                              )),
                          SizedBox(
                            height: 7,
                          ),
                          GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.getString("locale");
                                print("Locale: ${prefs.getString("locale")}");

                                prefs.getString("locale") == "ar"
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivacyPolicyScreen(
                                                  url:
                                                      'https://gomla.sa/exchange-policy-app-ar/',
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .return_and_exchange_policy,
                                                )),
                                      )
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivacyPolicyScreen(
                                                  url:
                                                      "https://gomla.sa/en/return-and-exchange-policy-app-en/",
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .return_and_exchange_policy,
                                                )),
                                      );
                              },
                              child: Text(
                                AppLocalizations.of(context)!
                                    .return_and_exchange_policy,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade500),
                              )),
                          SizedBox(
                            height: 7,
                          ),
                          GestureDetector(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.getString("locale");
                                print("Locale: ${prefs.getString("locale")}");

                                prefs.getString("locale") == "ar"
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivacyPolicyScreen(
                                                  url:
                                                      'https://gomla.sa/support-policy-app-ar/',
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .technical_support_and_customer_service_policy,
                                                )),
                                      )
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PrivacyPolicyScreen(
                                                  url:
                                                      "https://gomla.sa/en/customer-service-policy-app-en/",
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .technical_support_and_customer_service_policy,
                                                )),
                                      );
                              },
                              child: Text(
                                AppLocalizations.of(context)!
                                    .technical_support_and_customer_service_policy,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade500),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: mediaQueryHeight(context) * 0.06),
              Center(
                  child: Text(
                AppLocalizations.of(context)!.version,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              )),
              Center(
                  child: Text(
                AppLocalizations.of(context)!.all_rights_reserved,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey.shade100,
      leading: Icon(Icons.language, color: Colors.grey.shade500),
      title: Text(AppLocalizations.of(context)!.changeLanguage),
      trailing: LanguageSelector(),
      onTap: () {},
    );
  }

  Widget _buildDeleteAccount(BuildContext context) {
    // Get the current locale
    Locale currentLocale = Localizations.localeOf(context);

    // Determine the icon based on the current language (Arabic or English)
    IconData icon = currentLocale.languageCode == 'ar'
        ? Icons.keyboard_arrow_left_rounded // Example icon for Arabic
        : Icons.keyboard_arrow_right_outlined; // Default icon for English

    return ListTile(
      tileColor: Colors.grey.shade100,
      leading: Icon(Icons.security, color: Colors.grey.shade500),
      title: Text(AppLocalizations.of(context)!.securitySettings),
      trailing: Icon(icon,
          color: Colors.grey.shade500), // Change icon based on language
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeleteAccount()),
        );
      },
    );
  }

  Widget _buildShareApp(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey.shade100,
      leading: Icon(Icons.share, color: Colors.grey.shade500),
      title: Text(AppLocalizations.of(context)!.shareApp),
       onTap: () {
        _shareApp();
      },
    );
  }

  void _shareApp() {}
}
