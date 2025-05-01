import 'package:Gomla/providers/banner_repo.dart';
import 'package:Gomla/providers/home_screen_provider.dart';
import 'package:Gomla/providers/locale_provider.dart';
import 'package:Gomla/screens/brands_screen.dart';
import 'package:Gomla/screens/cart_screen.dart';
import 'package:Gomla/screens/categories_screen.dart';
import 'package:Gomla/screens/home_screen.dart';
import 'package:Gomla/screens/login_screen.dart';
import 'package:Gomla/screens/profile_screen.dart';
import 'package:Gomla/screens/registration_screen.dart';
import 'package:Gomla/screens/splash_screen.dart';
import 'package:Gomla/services/woocommerce_service.dart';
import 'package:Gomla/shared/utils/app_assets.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Engin/skin_cubit_and_states.dart';
import 'Engin/skincare.dart';
import 'controllers/categories_controller/categories_cubit.dart';
import 'models/banner.dart';
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
        BlocProvider(create: (_) => SkinAnalysisCubit()),
         BlocProvider(create: (_) => BrandsCubit(WooCommerceService())),
        BlocProvider(create: (_) => ProfileCubit()),
         ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => Fav()),
        ChangeNotifierProvider(create: (_) => HomeScreenProvider()),

        BlocProvider(create: (_) => LocaleCubit()),
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
