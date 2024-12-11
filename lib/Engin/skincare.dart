import 'dart:async';
import 'dart:io';

import 'package:Gomla/Engin/skincare_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import 'channel/perfectlib_channel.dart';
import 'channel/skincare_channel.dart';
import 'utility/styles.dart';
import 'utility/utility.dart';

enum SkincareState { suspend, waitForCountDown, countingDown, capturing }

class SkincareDetect extends StatefulWidget {
  const SkincareDetect({super.key});

  @override
  State<SkincareDetect> createState() => _SkincareDetectState();
}

class _SkincareDetectState extends State<SkincareDetect>
    with WidgetsBindingObserver {
  late Timer timer;
  late ImagePicker picker;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool perfectLibInited = false;
  bool _isLoading = false;

  late PerfectLibChannel perfectLibChannel;

  SkincareState currentState = SkincareState.suspend;
  double flashOpacity = 0.0;

  String faceLighting = "";
  String faceArea = '';
  String faceFront = '';

  int countDownTimer = 3;

  Widget loadingDialog(BuildContext context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: const Center(child: CircularProgressIndicator()),
        title: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(''),
        ),
      );

  @override
  void initState() {
    super.initState();

    // Initialize PerfectLib asynchronously
    initializePerfectLib();

    // Use addPostFrameCallback to delay dialog display until widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionDialog();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Safely access AppLocalizations here
    faceLighting = AppLocalizations.of(context)!.unknown;
  }

  // Asynchronous method to initialize PerfectLib
  Future<void> initializePerfectLib() async {
    var config = const PerfectLibConfiguration().build(
      PerfectImageSource.imageSourceUrl,
      false,
      // Developer mode
      false,
      // Preview mode
      true,
      // Mapping mode
      "",
      "android/app/src/main/assets/perfectlib/config.json",
      "android/app/src/main/assets/model",
    );

    perfectLibChannel = PerfectLibChannel();
    perfectLibChannel.onError = onError;

    try {
      final isInitialized = await perfectLibChannel.init(config);
      if (isInitialized) {
        await perfectLibChannel.setCountryCode('SA'); // Saudi Arabia
        await perfectLibChannel.setLocaleCode('en_US'); // Correct locale format
        setState(() {
          perfectLibInited = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          perfectLibInited = false;
          _isLoading = false;
        });
        _showErrorSnackbar(AppLocalizations.of(context)!.initializationFailed);
      }
    } catch (e) {
      setState(() {
        perfectLibInited = false;
        _isLoading = false;
      });
      _showErrorSnackbar(
          "${AppLocalizations.of(context)!.initializationError}: ${e.toString()}");
    }
  }

  // Show error as a Snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Utility function to show error messages as SnackBars

  void _showInstructionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.instructionsTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.removeMakeupInstruction),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.removeGlassesInstruction),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("Skincare AppLifecycleState onPaused");
      stopCountingDown();
    }
  }

  void updateLightQuality(
      String faceLighting, String faceArea, String faceFront) {
    if (!perfectLibInited) {
      return;
    }
    setState(() {
      this.faceLighting = faceLighting;
      this.faceArea = faceArea;
      this.faceFront = faceFront;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // State waitForCountDown

      if ((this.faceLighting == "Good" || this.faceLighting == "Normal") &&
          this.faceArea == "Good" &&
          this.faceFront == "Good") {
        if (currentState == SkincareState.waitForCountDown) {
          startCountingDown();
        }
      } else {
        if (currentState == SkincareState.countingDown) {
          stopCountingDown();
        }
      }
    });
  }

  void onCaptureImage(Image image) {
    analyzeImage(image);
  }

  void onCheckResult(Map data) {
    if (data["faceLighting"] != null &&
        data["faceArea"] != null &&
        data["faceFront"] != null) {
      if (kDebugMode) {
        print(
            "faceLighting: $faceLighting, faceArea: $faceArea, faceFront: $faceFront");
      }
      updateLightQuality(
          data["faceLighting"], data["faceArea"], data["faceFront"]);
    }
  }

  void onError(String error) {
    if (kDebugMode) {
      print("Error: $error");
    }
    _showErrorSnackbar(error);
  }

  void startCountingDown() {
    currentState = SkincareState.countingDown;
    countDownTimer = 3;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countDownTimer--;
        if (countDownTimer == 0) {
          timer.cancel();
          capture();
        }
      });
    });
  }

  void stopCountingDown() {
    timer.cancel();
    currentState = SkincareState.waitForCountDown;
  }

  Future<Image?> selectImageFromGallery() async {
    try {
      XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        return Image.file(File(imageFile.path));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error in selecting image: $e');
      }
      _showErrorSnackbar(e.toString());
      skincareViewChannel!.resume();
      return null;
    }
  }

  void capture() {
    currentState = SkincareState.capturing;
    setState(() {
      flashOpacity = 1.0;
    });
    // flash mode animation
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        flashOpacity = 0.0;
      });
      skincareViewChannel?.takePicture(); // Check null before calling
    });
  }

  Positioned selectImageView() {
    return Positioned(
        top: 90,
        left: 27,
        child: TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.pink),
          onPressed: () => {
            currentState = SkincareState.capturing,
            selectImageFromGallery()
                .then((imageFile) => {analyzeImage(imageFile)})
          },
          child: const Text(
            "Select Photo",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ));
  }

  void analyzeImage(Image? image) {
    if (image != null) {
      setState(() {
        _isLoading = true;
      });
      pause();
      Utility.resizeImage(image, 1600).then((resizedImage) => {
            skincareViewChannel!.analyzeImage(resizedImage).then((success) => {
                  if (success)
                    {
                      skincareViewChannel
                          !.getAvailableFeatures()
                          .then((skinFeatures) => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SkincareResult(
                                          faceImage: resizedImage,
                                          skinFeatures: skinFeatures,
                                          skincareViewChannel:
                                              skincareViewChannel!)),
                                ).then((value) => {
                                      setState(() {
                                        _isLoading = false;
                                        currentState =
                                            SkincareState.waitForCountDown;
                                      }),
                                      resume()
                                    })
                              })
                    }
                  else
                    {
                      // Alert Error ...
                      setState(() {
                        _isLoading = false;
                        currentState = SkincareState.waitForCountDown;
                      }),
                      resume()
                    }
                })
          });
    } else {
      setState(() {
        currentState = SkincareState.waitForCountDown;
      });
      resume();
    }
  }

  void pause() {
    if (skincareViewChannel == null) {
      _showErrorSnackbar("Skincare view is not initialized.");
      return;
    }
    skincareViewChannel?.pause();
  }

  void resume() {
    skincareViewChannel!.resume();
  }

  Positioned countDownAnimation(BuildContext context) {
    const Size viewSize = Size(250, 200);
    return Positioned(
      top: (MediaQuery.of(context).size.height - viewSize.height) / 2 - 50,
      left: (MediaQuery.of(context).size.width - viewSize.width) / 2,
      child: Container(
        width: viewSize.width,
        height: viewSize.height,
        color: Colors.transparent,
        child: Center(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.imageFindingText,
                // Localized text
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$countDownTimer',
                style: const TextStyle(
                  fontSize: 120,
                  shadows: <Shadow>[
                    Shadow(color: Colors.white, blurRadius: 5.0)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget skincareView(BuildContext context) {
    const String viewType = 'skincare_view';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'width': MediaQuery.of(context).size.width,
      'height': MediaQuery.of(context).size.height,
    };

    return Stack(
      children: [
        // Platform-specific view handling
        if (defaultTargetPlatform == TargetPlatform.android)
          PlatformViewLink(
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: {},
                creationParamsCodec: const StandardMessageCodec(),
                onFocus: () {
                  params.onFocusChanged(true);
                },
              )
                ..addOnPlatformViewCreatedListener((id) async {
                  params.onPlatformViewCreated(id);
                  onPlatformViewCreated(id);
                })
                ..create();
            },
            viewType: viewType,
          )
        else if (defaultTargetPlatform == TargetPlatform.iOS)
          UiKitView(
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: onPlatformViewCreated,
          )
        else
          throw UnsupportedError('Unsupported platform view'),

        // Circle overlay for face alignment
      ],
    );
  }

  ListView overallScoreView(BuildContext context) {
    List<Color> backgroundColors = [
      Colors.teal,
      Colors.indigo,
      // Add more colors if you have more overall score items
    ];

    List<Color> borderColors = [
      Colors.teal,
      Colors.indigo,
      // Add more colors if you have more overall score items
    ];

    // Localized labels for the overall score items
    List<String> overAllNames = [
      AppLocalizations.of(context)!.skinAge,
      // Localized for "skinAge"
      AppLocalizations.of(context)!.overallScore,
      // Localized for "overallScore"
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: overAllNames.length,
      itemBuilder: (context, index) {
        return scoreView(
          const Size(80, 50),
          '--',
          overAllNames[index], // Use localized name
          false,
          backgroundColors[index % backgroundColors.length], // Custom color
          borderColors[index % borderColors.length],
        );
      },
    );
  }

  Widget featureListView() {
    // Define custom colors for each index
    List<Color> backgroundColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      // Add more colors if you have more features
    ];

    List<Color> borderColors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      // Add more colors if you have more features
    ];

    List<String> featureNames = [
      AppLocalizations.of(context)!.moisture,
      // Localized for "moisture"
      AppLocalizations.of(context)!.oiliness,
      // Localized for "oiliness"
      AppLocalizations.of(context)!.redness,
      // Localized for "redness"
      AppLocalizations.of(context)!.texture,
      // Localized for "texture"
      AppLocalizations.of(context)!.wrinkle,
      // Localized for "wrinkle"
      AppLocalizations.of(context)!.age_spot,
      // Localized for "age_spot"
      AppLocalizations.of(context)!.acne,
      // Localized for "acne"
      AppLocalizations.of(context)!.dark_circle_v2,
      // Localized for "dark_circle_v2"
      AppLocalizations.of(context)!.pore,
      // Localized for "pore"
      AppLocalizations.of(context)!.radiance,
      // Localized for "radiance"
    ];

    return SizedBox(
      height: 100, // Define a fixed height to allow horizontal scrolling
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return scoreView(
            const Size(100, 50),
            '--',
            featureNames[index],
            false,
            backgroundColors[index % backgroundColors.length],
            // Use custom color
            borderColors[index % borderColors.length],
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            if (perfectLibInited) Center(child: skincareView(context)),

            // Black shadow overlay with a circular cutout
            Positioned.fill(
              child: Stack(
                children: [
                  // Circular cutout for the face area
                  Center(
                    child: Container(
                      width: 300,
                      // Adjust this size as needed to cover the face
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.adjustPosition,
                          // Localized string
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Flash overlay animation
            AnimatedOpacity(
              opacity: flashOpacity,
              duration: const Duration(milliseconds: 150),
              child: flashView(),
            ),

            // Light quality box and other widgets
            lightQualityBox(faceLighting, faceFront, faceArea, context),
            if (currentState == SkincareState.countingDown && perfectLibInited)
              countDownAnimation(context),
            if (_isLoading) loadingIndicator(),

            // Position for overall score view
            Positioned(
              top: 100.0,
              right: 0,
              left: MediaQuery.of(context).size.width * 0.25,
              child: SizedBox(
                height: 100,
                child: overallScoreView(
                  context
                ),
              ),
            ),

            // Feature list view positioned at the bottom with full width and adjusted height
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: featureListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    skincareViewChannel?.stop();
    skincareViewChannel?.dispose();
    perfectLibChannel.unload();
    currentState = SkincareState.suspend;
    timer.cancel();
    super.dispose();
  }

// In your onPlatformViewCreated method
// Declare the channel without late keyword
  SkincareViewChannel? skincareViewChannel;

  void onPlatformViewCreated(int id) {
    setState(() {
      currentState = SkincareState.waitForCountDown;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure initialization happens
      skincareViewChannel = SkincareViewChannel(id);
      skincareViewChannel?.start();
      skincareViewChannel?.onCaptureImage = onCaptureImage;
      skincareViewChannel?.onCheckResult = onCheckResult;
      skincareViewChannel?.onError = onError;
    });
  }
}



