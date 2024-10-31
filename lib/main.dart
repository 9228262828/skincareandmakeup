import 'package:flutter/material.dart';

import 'makeupCam.dart';
import 'skincare.dart';
import 'utility/styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkinCareDemo());
}

class SkinCareDemo extends StatelessWidget {
  const SkinCareDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDK Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SettingPage(title: 'Skin Care Demo'),
    );
  }
}

class SettingPage extends StatelessWidget {
  const SettingPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(title),
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
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MakeupCam()),
                  );*/
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
          ],
        ),
      ),
    );
  }
}
