import 'package:flutter/material.dart';
import 'package:skincare/providers/home_screen_provider.dart';
import 'package:skincare/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:skincare/contstants.dart';
import 'package:skincare/models/cart.dart';
import 'package:skincare/models/fav.dart';
import 'package:skincare/providers/locale_provider.dart';
import 'package:skincare/screens/brands_screen.dart';
import 'package:skincare/screens/categories_screen.dart';
import 'package:skincare/screens/home_screen.dart';
import 'package:skincare/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skincare/screens/brands_screen.dart';
import 'package:skincare/screens/cart_screen.dart';
import 'package:skincare/screens/categories_screen.dart';
import 'package:skincare/screens/home_screen.dart';
import 'package:skincare/screens/profile_screen.dart';

import 'Engin/ads.dart';
import 'Engin/makeupCam.dart';
import 'Engin/skincare.dart';
import 'contstants.dart';


void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => Fav()),
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
        ChangeNotifierProxyProvider<LocaleProvider, HomeScreenProvider>(
          create: (_) => HomeScreenProvider(),
          update: (context, localeProvider, homeScreenProvider) {
            homeScreenProvider!.refreshData(context);
            return homeScreenProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Gomlaa',
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.pink,
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.cairoTextTheme(),
          ),
          home:  SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<HomeScreenProvider>(context, listen: false)
        .fetchInitialData(context);
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenProvider = Provider.of<HomeScreenProvider>(context);
    double size = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String splashImage;

    if (size < 480) {
      splashImage = 'assets/800-1600.png';
    } else if (size < 720) {
      splashImage = 'assets/x.png';
    } else if (size < 960) {
      splashImage = 'assets/xx.png';
    } else {
      splashImage = 'assets/xx.png';
    }

    return const Scaffold(
      body: MainScreen(),
    );
  }
}

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;

//   static final List<Widget> _widgetOptions = <Widget>[
//     const HomeScreen(),
//     CategoriesScreen(),
//     BrandsScreen(),
//     const ProfileScreen(),
//     CartScreen()
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _widgetOptions.elementAt(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.home_outlined),
//             label: AppLocalizations.of(context)!.home,
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.photo_album_rounded),
//             label: AppLocalizations.of(context)!.categories,
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.badge_rounded),
//             label: AppLocalizations.of(context)!.brands,
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.account_circle),
//             label: AppLocalizations.of(context)!.profile,
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.shopping_cart),
//             label: AppLocalizations.of(context)!.cart,
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: mainColor,
//         unselectedItemColor: Colors.black,
//         unselectedLabelStyle: const TextStyle(color: Colors.black),
//         showUnselectedLabels: true,
//         onTap: _onItemTapped,
//         selectedLabelStyle: const TextStyle(fontSize: 12),
//         unselectedFontSize: 10,
//         backgroundColor: Colors.white,
//         landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }
// }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    CategoriesScreen(),
    BrandsScreen(),
    const ProfileScreen(),
    CartScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.photo_album_rounded),
          label: AppLocalizations.of(context)!.categories,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.badge_rounded),
          label: AppLocalizations.of(context)!.brands,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_circle),
          label: AppLocalizations.of(context)!.profile,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_cart),
          label: AppLocalizations.of(context)!.cart,
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: mainColor,
      unselectedItemColor: Colors.black,
      unselectedLabelStyle: const TextStyle(color: Colors.black),
      showUnselectedLabels: true,
      onTap: onItemTapped,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedFontSize: 10,
      backgroundColor: Colors.white,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      type: BottomNavigationBarType.fixed,
    );
  }
}

class SkinPage extends StatelessWidget {
  const SkinPage({super.key, });



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Skin Care",style: TextStyle(color: Colors.white),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
             SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            TextButton(
                style: TextButton.styleFrom(
                  side:   BorderSide(color: Colors.pink),
                    backgroundColor: Colors.white,
                    fixedSize:  Size(250, MediaQuery.of(context).size.height * 0.3),),
                child: const Text('MakeupCam'),
                onPressed: () {
                  // Navigate to a new page when the button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MakeupCam()),
                  );
                }),
            const SizedBox(height: 25),
            TextButton(
                style: TextButton.styleFrom(
                  side:   BorderSide(color: Colors.pink),
                  backgroundColor: Colors.white,
                  fixedSize:  Size(250, MediaQuery.of(context).size.height * 0.3),),
                child: const Text('Skincare'),
                onPressed: () {
                  // Navigate to a new page when the button is pressed

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SkincareDetect()),
                  );
                }),

           /* TextButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AdPage()),
              );
            }, child:  Text("ads"))*/
          ],
        ),
      ),
    );
  }
}
