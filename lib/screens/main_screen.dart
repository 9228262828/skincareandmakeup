import 'package:Gomla/screens/brands_screen.dart';
import 'package:Gomla/screens/cart_screen.dart';
import 'package:Gomla/screens/categories_screen.dart';
import 'package:Gomla/screens/home_screen.dart';
import 'package:Gomla/screens/product_screen.dart';
import 'package:Gomla/screens/profile_screen.dart';
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../contstants.dart';
import '../models/banner.dart';
import '../models/cart.dart';


class MainScreen extends StatefulWidget {
  final List<Bannerr>? banners;
 int ?index;

    MainScreen({Key? key, this.banners, required this.index}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  void _onItemTapped(int index) {
    setState(() {
      widget.index = index;
    });
  }

  Widget _getIcon(String assetPath, bool isSelected) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        isSelected ? mainColor : Colors.black, // Change color if selected
        BlendMode.srcIn,
      ),
      child: SvgPicture.asset(
        assetPath,
        height: 22.0,
        width: 25.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Bannerr> banners = widget.banners ?? [];

    final List<Widget> _widgetOptions = <Widget>[
      HomeScreen(
        banners: banners,
        ontap: () {
          _onItemTapped(5);
        },
      ),
      BrandsScreen(),
      CategoriesScreen(),

      ProfileScreen(),
      CartScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: widget.index,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Consumer<Cart>(
        builder: (context, cart, child) {
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.home, widget.index == 0),
                label: AppLocalizations.of(context)!.home,
              ),

              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.sale, widget.index == 1),
                label: AppLocalizations.of(context)!.brands,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.category, widget.index == 2),
                label: AppLocalizations.of(context)!.categories,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.account, widget.index == 3),
                label: AppLocalizations.of(context)!.profile,
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _getIcon(ImageAssets.cart, widget.index == 4),
                    ),
                    if (cart.items.length > 0) // Show badge only if cart has items
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            cart.items.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: AppLocalizations.of(context)!.cart,
              ),
            ],
            currentIndex: widget.index!,
            selectedItemColor: mainColor,
            unselectedItemColor: Colors.black,
            unselectedLabelStyle: TextStyle(color: Colors.black),
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            selectedLabelStyle: TextStyle(fontSize: 12),
            unselectedFontSize: 10,
            backgroundColor: Colors.white,
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            type: BottomNavigationBarType.fixed,
          );
        },
      ),
    );
  }
}
