import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

  String faceLighting = 'Unknown';
  String faceArea = 'Unknown';
  String faceFront = 'Unknown';

  int countDownTimer = 3;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    // Init perfectLib
    var config = const PerfectLibConfiguration().build(
        PerfectImageSource.imageSourceUrl,
        false,
        false,
        true,
        "",
       "android/app/src/main/assets/perfectlib/config.json",
         "android/app/src/main/assets/model"
    );
    perfectLibChannel = PerfectLibChannel();
    perfectLibChannel.onError = onError;
    perfectLibChannel.init(config).then((isSuccess) => {
          setState(() {
            perfectLibInited = isSuccess;
          }),
          perfectLibChannel.setCountryCode('us'),
          perfectLibChannel.setLocaleCode('en_us')
        });
    // Initialize Imagepicker
    timer = Timer(const Duration(seconds: 1), () {});
    picker = ImagePicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("Skincare AppLifecycleState onPaused");
      stopCountingDown();
    }
  }

  void _showErrorSnackbar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      showErrorDialog(errorMessage),
    );
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
      skincareViewChannel!.takePicture();
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
    skincareViewChannel!.pause();
  }

  void resume() {
    skincareViewChannel!.resume();
  }

  Positioned countDownAnimation(BuildContext context) {
    const Size viewSize = Size(80, 150);
    return Positioned(
      top: (MediaQuery.of(context).size.height - viewSize.height) / 2 - 50,
      left: (MediaQuery.of(context).size.width - viewSize.width) / 2,
      child: Container(
        width: viewSize.width,
        height: viewSize.height,
        color: Colors.transparent,
        child: Center(
            child: Text(
          '$countDownTimer',
          style: const TextStyle(
              fontSize: 120,
              shadows: <Shadow>[Shadow(color: Colors.white, blurRadius: 5.0)]),
        )),
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
        Center(
          child: Container(
            width: 200, // Adjust the size as needed
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.6), // Border color
                width: 4.0, // Border width
              ),
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          if (perfectLibInited) Center(child: skincareView(context)),
          AnimatedOpacity(
              opacity: flashOpacity,
              duration: const Duration(microseconds: 150),
              child: flashView()),
          backButton(context),
          selectImageView(),
          lightQualityBox(faceLighting, faceFront, faceArea),
          if (currentState == SkincareState.countingDown && perfectLibInited)
            countDownAnimation(context),
          if (_isLoading) loadingIndicator()
        ],
      ),
    );
  }

  late SkincareViewChannel? skincareViewChannel;

// In your dispose method
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
  void onPlatformViewCreated(int id) {
    setState(() {
      currentState = SkincareState.waitForCountDown;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      skincareViewChannel = SkincareViewChannel(id); // Ensure initialization happens
      skincareViewChannel!.start();
      skincareViewChannel!.onCaptureImage = onCaptureImage;
      skincareViewChannel!.onCheckResult = onCheckResult;
      skincareViewChannel!.onError = onError;
    });
  }

}

class SkincareResult extends StatefulWidget {
  const SkincareResult(
      {super.key,
      required this.faceImage,
      required this.skinFeatures,
      required this.skincareViewChannel});

  final List<String> skinFeatures;
  final Image faceImage;
  final SkincareViewChannel skincareViewChannel;

  @override
  State<SkincareResult> createState() => _SkincareResultState();
}

class _SkincareResultState extends State<SkincareResult> {
  List<String> selectedSkinFeatures = [];
  Map<String, String>? reports;
  Map<String, String>? scores;
  Map<String, String>? skinTypes;
  bool isShowSkinType = false;
  late Image faceImage = widget.faceImage;

  void updateSkinTypeResult() {
    // Use getSkinTypes to update the report
    setState(() {
      isShowSkinType = !isShowSkinType;
    });

    if (isShowSkinType) {
      widget.skincareViewChannel.getSkinTypeAnalyzedImage().then((image) => {
            setState(() {
              faceImage = image!;
            })
          });
    } else {
      widget.skincareViewChannel
          .getAnalyzedImage(selectedSkinFeatures)
          .then((image) => {
                setState(() {
                  faceImage = image!;
                })
              });
    }
  }

  void updateSelectedFeatures(String feature, bool isAdd) {
    // Update the features
    if (isAdd) {
      selectedSkinFeatures.add(feature);
    } else {
      if (selectedSkinFeatures.firstWhere((element) => element == feature,
              orElse: () => "") !=
          "") {
        selectedSkinFeatures.remove(feature);
      }
    }

    widget.skincareViewChannel
        .getAnalyzedImage(selectedSkinFeatures)
        .then((image) => {
              setState(() {
                faceImage = image!;
                isShowSkinType = false;
              })
            });
  }

  ListView featureListView(Map<String, String>? reports) {
    if (reports == null) {
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.skinFeatures.length,
          itemBuilder: (context, index) {
            return scoreView(
                const Size(80, 50), '--', widget.skinFeatures[index], false);
          });
    } else {
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.skinFeatures.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                onTap: () {
                  updateSelectedFeatures(
                      widget.skinFeatures[index],
                      !selectedSkinFeatures
                          .contains(widget.skinFeatures[index]));
                },
                child: scoreView(
                    const Size(80, 50),
                    reports[widget.skinFeatures[index]].toString(),
                    widget.skinFeatures[index],
                    isShowSkinType
                        ? false
                        : selectedSkinFeatures
                            .contains(widget.skinFeatures[index])));
          });
    }
  }

  ListView overallScoreView(Map<String, String>? scores) {
    List<String> overAllNames = ['skinAge', 'overallScore'];
    if (scores == null) {
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: overAllNames.length,
          itemBuilder: (context, index) {
            return scoreView(
                const Size(80, 50), '--', overAllNames[index], false);
          });
    } else {
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: overAllNames.length,
          itemBuilder: (context, index) {
            return scoreView(
                const Size(80, 50),
                scores[overAllNames[index]].toString(),
                overAllNames[index],
                false);
          });
    }
  }

  Row skinTypeView(Map<String, String>? skinTypes) {
    if (skinTypes == null) {
      return const Row();
    } else {
      return Row(children: [
        GestureDetector(
            onTap: () {
              updateSkinTypeResult();
            },
            child: scoreView(const Size(20, 20), "", "", isShowSkinType)),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("FullFace: ${skinTypes['FullFace'].toString()}",
                style: glowingText()),
            Text("T-Zone: ${skinTypes['T-Zone'].toString()}",
                style: glowingText()),
            Text("U-Zone: ${skinTypes['U-Zone'].toString()}",
                style: glowingText()),
          ],
        )
      ]);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Update skincare by sequence reports then overall score.
      widget.skincareViewChannel.getReports().then((reports) => {
            widget.skincareViewChannel.getOverallScore().then((scores) => {
                  widget.skincareViewChannel
                      .getSkinTypes()
                      .then((skinTypes) => {
                            setState(() {
                              this.reports = reports;
                              this.scores = scores;
                              this.skinTypes = skinTypes;
                            })
                          })
                })
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width, // Full width
                child: Hero(
                  tag: 'AnalyzedImage',
                  child: Image(
                    gaplessPlayback: true,
                    image: faceImage.image,
                    fit: BoxFit
                        .cover, // Maintain aspect ratio and cover the entire container
                  ),
                )),
          ),
          Positioned(
              top: 100.0,
              right: 0,
              left: 16.0,
              child: SizedBox(
                height: 100,
                child: overallScoreView(scores),
              )),
          Positioned(
              top: 180,
              right: 0,
              left: 26,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 100,
                    child: skinTypeView(skinTypes),
                  ))),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 150,
                child: featureListView(reports),
              )),
          backButton(context),
        ],
      ),
    );
  }
}
