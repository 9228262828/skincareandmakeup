import 'package:Gomla/Engin/skincare.dart';
import 'package:Gomla/screens/delete_account_Screen.dart';
import 'package:Gomla/screens/policy_screen.dart';
import 'package:Gomla/screens/terms_screen.dart';
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../widgets/account_shimmer.dart';
import '../widgets/language_selector.dart';
import '../widgets/unauth_widget.dart';
import 'fav_screen.dart';
import 'help_screen.dart';
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

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..fetchUserInfo(context),
      child: Scaffold(
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
              SizedBox(
                height: mediaQueryHeight(context) * 0.04,
              ),
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
              SizedBox(height: 20),

              SizedBox(height: mediaQueryHeight(context) * 0.02),
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
              SizedBox(height: mediaQueryHeight(context) * 0.06),
              GestureDetector(
                onTap: () {
                  context.read<ProfileCubit>().logout();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                },
                child: Container(
                  height: mediaQueryHeight(context) * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(AppLocalizations.of(context)!.logout,
                          style: TextStyle(
                            color: mainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                          )),
                      Icon(
                        Icons.logout,
                        color: mainColor,
                        size: 25,
                      )
                    ],
                  )),
                ),
              ),
              SizedBox(height: mediaQueryHeight(context) * 0.02),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.sellwithus,
                        style: TextStyle(
                            color: mainColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: mediaQueryHeight(context) * 0.01),
                    Divider(
                      color: Colors.grey.shade300,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TermsAndConditionsPage()),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.termsOfUse,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ),  TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PrivacyPolicyPage()),
                                  );
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.privacyPolicy,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey.shade500)),
                              ),
                            ],
                          ),
                          /*TextButton(
                            onPressed: () {},
                            child: Text(
                              AppLocalizations.of(context)!.helpSupport,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade500),
                            ),
                          ),*/

                          /*TextButton(
                            onPressed: () {},
                            child: Text(
                                AppLocalizations.of(context)!.delveryPolicy,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade500)),
                          ),*/
                          SizedBox(height: mediaQueryHeight(context) * 0.02),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /*  TextButton(
                            onPressed: () {},
                            child: Text(
                              AppLocalizations.of(context)!.termsOfUse,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ),*/
                              /*TextButton(
                            onPressed: () {},
                            child: Text(
                              AppLocalizations.of(context)!.faqs,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              AppLocalizations.of(context)!.shareApp,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ),*/
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
    return ListTile(
      tileColor: Colors.grey.shade100,
      leading: Icon(Icons.security, color: Colors.grey.shade500),
      title: Text(AppLocalizations.of(context)!.securitySettings),
      trailing: Icon(Icons.keyboard_arrow_left, color: Colors.grey.shade500),
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
      trailing: Icon(Icons.keyboard_arrow_left, color: Colors.grey.shade500),
      onTap: () {
        _shareApp();
      },
    );
  }

  void _shareApp() {}
}
