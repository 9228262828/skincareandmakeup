import 'package:Gomla/providers/home_screen_provider.dart';
import 'package:Gomla/providers/locale_provider.dart';
import 'package:Gomla/screens/brands_screen.dart';
import 'package:Gomla/screens/cart_screen.dart';
import 'package:Gomla/screens/categories_screen.dart';
import 'package:Gomla/screens/home_screen.dart';
import 'package:Gomla/screens/login_screen.dart';
import 'package:Gomla/screens/profile_screen.dart';
import 'package:Gomla/services/woocommerce_service.dart';
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Engin/skincare.dart';
import 'test.dart';
import 'Engin/utility/makeupCam.dart';
import 'controllers/brands_controller/brands_cubit.dart';
import 'contstants.dart';
import 'models/cart.dart';
import 'models/fav.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        BlocProvider(create: (_) => ProductsCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => Fav()),
        ChangeNotifierProvider(create: (_) => Fav()),
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
        BlocProvider(create: (_) => LocaleCubit()),
        ChangeNotifierProxyProvider<LocaleCubit, HomeScreenProvider>(
          create: (_) => HomeScreenProvider(),
          update: (context, localeCubit, homeScreenProvider) {
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
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) {
        return MaterialApp(
          title: 'Gomla',
          locale: locale,
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
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String savedLocale = prefs.getString("locale")?? "ar";

      print('Stored locale: $savedLocale'); // Debugging print

     determineNavigation();
    });
  }
  Future<void> determineNavigation() async {
    final prefs = await SharedPreferences.getInstance();


    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    print('isFirstLaunch: $isFirstLaunch');

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('isLoggedIn: $isLoggedIn');

    final token = prefs.getString('auth_token');
    print('auth_token: $token');

    if (isFirstLaunch) {
      await prefs.setBool(
          'isFirstLaunch', false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OpenScreen()),
      );
      return;
    }



      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );

  }


  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String splashImage;

    if (size < 480) {
      splashImage = 'assets/app_icon.png';
    } else if (size < 720) {
      splashImage = 'assets/app_icon.png';
    } else if (size < 960) {
      splashImage = 'assets/app_icon.png';
    } else {
      splashImage = 'assets/app_icon.png';
    }

    return Scaffold(
      body: Center(
        child: Image.asset(
          splashImage,
          width: MediaQuery.of(context).size.width * .85,
          height: MediaQuery.of(context).size.height * .2,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    CategoriesScreen(),
    BrandsScreen(),
     ProfileScreen(),
    CartScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Consumer<Cart>(
        builder: (context, cart, child) {
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.home, _selectedIndex == 0),
                label: AppLocalizations.of(context)!.home,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.category, _selectedIndex == 1),
                label: AppLocalizations.of(context)!.categories,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.sale, _selectedIndex == 2),
                label: AppLocalizations.of(context)!.brands,
              ),
              BottomNavigationBarItem(
                icon: _getIcon(ImageAssets.account, _selectedIndex == 3),
                label: AppLocalizations.of(context)!.profile,
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: _getIcon(ImageAssets.cart, _selectedIndex == 4),
                    ),
                    if (cart.items.length > 0) // Show badge only if cart has items
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
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
            currentIndex: _selectedIndex,
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
