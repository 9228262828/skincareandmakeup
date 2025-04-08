import 'dart:async';
import 'dart:io';
import 'package:Gomla/Engin/skincare_result.dart';
import 'package:Gomla/Engin/widgets.dart';
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
  SkincareViewChannel? skincareViewChannel;

  @override
  void initState() {
    super.initState();
    initializePerfectLib();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInstructionDialog(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    faceLighting = AppLocalizations.of(context)!.unknown;
  }

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
      Platform.isAndroid
          ? "android/app/src/main/assets/config.json"
          : "ios/Runner/Assets/perfectlib/config.json",
      Platform.isAndroid
          ? "android/app/src/main/assets/model"
          : "ios/Runner/Assets/model",
    );

    perfectLibChannel = PerfectLibChannel();
    perfectLibChannel.onError = onError;

    try {
      final isInitialized = await perfectLibChannel.init(config);
      if (isInitialized) {
        await perfectLibChannel.setCountryCode('SA');
        await perfectLibChannel.setLocaleCode('en_US');
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget skincareView(BuildContext context) {
    const String viewType = 'skincare_view';
    final creationParams = <String, dynamic>{
      'width': MediaQuery.of(context).size.width,
      'height': MediaQuery.of(context).size.height,
    };

    return Stack(children: [
      if (defaultTargetPlatform == TargetPlatform.android)
        PlatformViewLink(
          surfaceFactory: (context, controller) => AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          ),
          onCreatePlatformView: (params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
              creationParams: {},
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
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
    ]);
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      stopCountingDown();
    }
  }

  void updateLightQuality(String faceLighting, String faceArea, String faceFront) {
    if (!perfectLibInited) return;
    setState(() {
      this.faceLighting = faceLighting;
      this.faceArea = faceArea;
      this.faceFront = faceFront;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  void onCaptureImage(Image image) => analyzeImage(image);

  void onError(String error) {
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

  void capture() {
    currentState = SkincareState.capturing;
    setState(() {
      flashOpacity = 1.0;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        flashOpacity = 0.0;
      });
      skincareViewChannel?.takePicture();
    });
  }

  Future<Image?> selectImageFromGallery() async {
    final picker = ImagePicker();
    try {
      XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        return Image.file(File(imageFile.path));
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    }
    skincareViewChannel?.resume();
    return null;
  }

  void analyzeImage(Image? image) {
    if (image != null) {
      setState(() => _isLoading = true);
      pause();
      Utility.resizeImage(image, 1600).then((resizedImage) {
        skincareViewChannel?.analyzeImage(resizedImage).then((success) {
          if (success) {

            skincareViewChannel?.getAvailableFeatures().then((skinFeatures) {
              print("skinFeatures.length");
              print(skinFeatures.length);
              print(skinFeatures[0]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SkincareResult(
                    faceImage: resizedImage,
                    skinFeatures: skinFeatures,
                    skincareViewChannel: skincareViewChannel!,
                  ),
                ),
              ).then((_) {
                setState(() {
                  _isLoading = false;
                  currentState = SkincareState.waitForCountDown;
                });
                resume();
              });
            });
          } else {
            setState(() {
              _isLoading = false;
              currentState = SkincareState.waitForCountDown;
            });
            resume();
          }
        });
      });
    } else {
      setState(() {
        currentState = SkincareState.waitForCountDown;
      });
      resume();
    }
  }

  void pause() => skincareViewChannel?.pause();
  void resume() => skincareViewChannel?.resume();

  void onPlatformViewCreated(int id) {
    setState(() => currentState = SkincareState.waitForCountDown);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      skincareViewChannel = SkincareViewChannel(id)
        ..start()
        ..onCaptureImage = onCaptureImage
        ..onCheckResult = onCheckResult
        ..onError = onError;
    });
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
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.adjustPosition,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: flashOpacity,
              duration: const Duration(milliseconds: 150),
              child: flashView(),
            ),
            Positioned(

                child: backButton(context)),
            lightQualityBox(faceLighting, faceFront, faceArea, context),
            if (currentState == SkincareState.countingDown && perfectLibInited)
              countDownAnimation(context),
            if (_isLoading) loadingIndicator(),
          ],
        ),
      ),
    );
  }
}
