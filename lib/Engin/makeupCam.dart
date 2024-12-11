/*
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'channel/lookhandler_channel.dart';
import 'channel/makeupCam_channel.dart';
import 'channel/perfectlib_channel.dart';
import 'channel/skuhandler_channel.dart';
import 'utility/styles.dart';
import 'utility/utility.dart';

class MakeupCam extends StatefulWidget {
  const MakeupCam({super.key});

  @override
  State<MakeupCam> createState() => _MakeupCamState();
}

class _MakeupCamState extends State<MakeupCam> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool perfectLibInited = false;
  bool _isLoading = true;
  bool _isShowProgress = false;
  double _progressValue = 0;
  String? _currentFeatureRoom;
  String? _currentSelectedProduct;
  String? _currentSelectedSku;
  String? _currentSelectedPattern;
  String? _currentSelectedWearingStyle;
  String? _currentSelectedPalette;
  int? _currentSelectedSkuIndex = null;

  int _currentSelectedLook = 0;
  Map _intensityValues = {};
  late MakeupCamViewChannel makeupCamViewChannel;
  late SkuHandler skuHandler;
  late LookHandler lookHandler;
  late PerfectLibChannel perfectLibChannel;

  @override
  void initState() {
    super.initState();

    // Initialize PerfectLib asynchronously
    initializePerfectLib();
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
      "android/app/src/main/assets/perfectlib/config.json",
      "android/app/src/main/assets/model",
    );

    perfectLibChannel = PerfectLibChannel();
    perfectLibChannel.onError = onError;

    try {
      final isInitialized = await perfectLibChannel.init(config);
      if (isInitialized) {
        await perfectLibChannel.setCountryCode('SA');
        await perfectLibChannel.setLocaleCode('enu');
        setState(() {
          perfectLibInited = true;
          _isLoading = false;
        });
        print("Successfully initialized PerfectLib");
      } else {
        setState(() {
          perfectLibInited = false;
          _isLoading = false;
        });
        print("Failed to initialize PerfectLib");
        _showErrorSnackbar(AppLocalizations.of(context)!.initializationFailed);
      }
    } catch (e) {
      setState(() {
        perfectLibInited = false;
        _isLoading = false;
      });
      print("Error initializing PerfectLib: $e");
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

  Widget skuListBar(BuildContext context) {
    if (_currentSelectedProduct == null ||
        _currentFeatureRoom == PerfectEffect.background.name) {
      return Container(height: 60);
    }
    return FutureBuilder(
        future: skuList(context, _currentSelectedProduct!),
        builder: (BuildContext context, AsyncSnapshot<Widget> skuList) {
          return SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: skuList.data);
        });
  }

  Widget productListBar(BuildContext context) {
    if (_currentFeatureRoom == null) {
      return Container(height: 80);
    }
    return FutureBuilder(
        future: productList(context),
        builder: (BuildContext context, AsyncSnapshot<Widget> productList) {
          return SizedBox(
              height: 80,
              width: MediaQuery.of(context).size.width,
              child: productList.data);
        });
  }

  Widget lookListBar(BuildContext context) {
    if (_currentFeatureRoom == null) {
      return Container(height: 80);
    }
    return FutureBuilder(
        future: lookList(context),
        builder: (BuildContext context, AsyncSnapshot<Widget> lookList) {
          return SizedBox(
              height: 80,
              width: MediaQuery.of(context).size.width,
              child: lookList.data);
        });
  }

  Widget featureListBar(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: featureList(context),
    );
  }

  Widget controlPanel(BuildContext context) {
    return Positioned(
        bottom: 0,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              _currentFeatureRoom == PerfectEffect.earrings.name
                  ? wearingStyleListBar(context)
                  : patternListBar(context),
              skuListBar(context),
              if (_currentFeatureRoom != null)
                _currentFeatureRoom == "Look"
                    ? lookListBar(context)
                    : productListBar(context),
              featureListBar(context),
              const SizedBox(height: 5),
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  children: [_photoButton()],
                ),
              )
            ]));
  }

  Widget _photoButton() {
    return Column(children: [
      const SizedBox(height: 5),
      cameraButton(() async {
        setState(() {
          _isLoading = true;
        });
        String? data = await makeupCamViewChannel.takePicture();
        if (data != null) {
          ui.Image image =
              await decodeImageFromList(Utility.base64ToBytes(data));
          bool result = await Utility.saveImageToGallery(image);
          setState(() {
            _isLoading = false;
          });
          if (result) {
            _showSuccessSnackbar(
                'Successfully taken the photo and save in gallery');
          } else {
            _showErrorSnackbar('Failed in caputring the photo');
          }
        }
      }),
    ]);
  }

  Future<Widget> lookList(BuildContext context) async {
    List list = await lookHandler.getList();
    // Add clear button
    list.insert(0, {});
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(0),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return TextButton(
              onPressed: () {
                setState(() {
                  _currentSelectedLook = index;
                });
                if (index == 0) {
                  makeupCamViewChannel.clearAllEffects();
                } else {
                  makeupCamViewChannel.applyLook(list[index]["guid"]);
                }
              },
              child: Container(
                  width: 45,
                  height: 80,
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: _currentSelectedLook == index && index != 0
                        ? Colors.pink
                        : Colors.transparent, // Border color
                    width: 1.0,
                  )),
                  child: Column(children: [
                    index == 0
                        ? const Icon(
                            Icons.not_interested,
                            color: Colors.white,
                            size: 60.0,
                          )
                        : _loadImage(
                            list[index]["thumbnail"], 50, BoxFit.cover),
                    if (index > 0)
                      Flexible(
                          child: Text(list[index]["name"],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black)))
                  ])));
        });
  }

  Future<Widget> productList(BuildContext context) async {
    PerfectEffect effect =
        PerfectEffect.values.firstWhere((e) => e.name == _currentFeatureRoom);
    List list = await skuHandler.getList(effect);
    if (effect == PerfectEffect.background) {
      list.insert(0, {});
    }
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(0),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return TextButton(
              onPressed: () {
                setState(() {
                  _currentSelectedProduct = list[index]["guid"];
                  _currentSelectedSku = null;
                  _currentSelectedSkuIndex = null;
                  _currentSelectedPattern = null;
                });
                if (effect == PerfectEffect.background) {
                  if (index == 0) {
                    makeupCamViewChannel
                        .clear(effectNameToPerfectEffect(effect.name));
                  } else {
                    makeupCamViewChannel.apply(const VtoSetting()
                        .create(list[index]["guid"], "", "", "", ""));
                  }
                }
              },
              style: TextButton.styleFrom(minimumSize: const Size(50, 80)),
              child: SizedBox(
                  width: 50,
                  height: 80,
                  child: Column(children: [
                    index == 0 && effect == PerfectEffect.background
                        ? const Icon(
                            Icons.not_interested,
                            color: Colors.white,
                            size: 60.0,
                          )
                        : _loadImage(
                            list[index]["thumbnail"], 50, BoxFit.cover),
                    if (effect != PerfectEffect.background)
                      Flexible(
                          child: Text(list[index]["name"],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black)))
                  ])));
        });
  }

  Future<Widget> colorCell(
      BuildContext context, Map sku, bool isSelected) async
  {
    List palettes = await skuHandler.getPalettes(sku['guid'], "");
    Map palette = palettes.first;
    List colors = palette['colors'];

    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                width: 2, color: isSelected ? Colors.red : Colors.transparent)),
        child: CircleAvatar(
          radius: 45,
          backgroundColor: HexColor.fromHex(colors.first!),
        ));
  }

  Widget wearingStyleListBar(BuildContext context) {
    if (_currentSelectedSku == null && _currentSelectedWearingStyle == null) {
      return Container(height: 50);
    }
    return FutureBuilder(
        future: wearingStyleList(context),
        builder:
            (BuildContext context, AsyncSnapshot<Widget> wearingStyleList) {
          return SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: wearingStyleList.data);
        });
  }

  Future<Widget> wearingStyleList(BuildContext context) async {
    if (_currentSelectedSku == null && _currentSelectedPattern == null) {
      return Container(height: 50);
    }
    List list = await skuHandler.getWearingStyles(_currentSelectedSku!, "");
    if (_currentSelectedWearingStyle == null) {
      setState(() {
        // Default select first index
        _currentSelectedWearingStyle = list[0]["guid"];
      });
    }

    return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(0),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return TextButton(
              onPressed: () {
                setState(() {
                  _currentSelectedWearingStyle = list[index]["guid"];
                });
                makeupCamViewChannel.apply(const VtoSetting().create(
                    _currentSelectedProduct!,
                    _currentSelectedSku!,
                    "",
                    "",
                    list[index]["guid"]));
              },
              style: TextButton.styleFrom(minimumSize: const Size(50, 80)),
              child: FutureBuilder(
                  future: wearingStyleCell(context, list[index],
                      _currentSelectedWearingStyle == list[index]["guid"]),
                  builder: (BuildContext context,
                      AsyncSnapshot<Widget> wearingStyleList) {
                    return SizedBox(
                        height: 45, width: 45, child: wearingStyleList.data);
                  }));
        });
  }

  Future<Widget> wearingStyleCell(
      BuildContext context, Map wearingStyle, bool isSelected) async
  {
    if (wearingStyle["guid"] == null || wearingStyle["guid"] == "") {
      return Container();
    }
    return Container(
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(5.0)),
      child: Center(
          child: Text(wearingStyle['name'],
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 10, color: Colors.black, height: 1))),
    );
  }
  List  selectedPatterns = []; // Store selected patterns

  void _removePatternFromList(int index) {
    setState(() {
      selectedPatterns.removeAt(index);  // Remove the selected pattern by index
    });
  }
  Widget _buildSelectedPatternsList() {
    return Positioned(
      top: 100, // Adjust as needed
      right: 20, // Position on the right side
      child: Container(
        width: 120,

        // Set the width as per your design
        height: MediaQuery.of(context).size.height*.2,
        color: Colors.black.withOpacity(0.3),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: selectedPatterns.length,
          itemBuilder: (context, index) {
            var pattern = selectedPatterns[index];
            return Card(
              color: Colors.white,
              child: ListTile(
                leading: _loadImage(pattern['thumbnail'], 30, BoxFit.cover), // Display thumbnail
                title: Text(pattern['name']),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    _removePatternFromList(index); // Remove the selected pattern from the list
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget patternListBar(BuildContext context) {
    if ((_currentSelectedSku == null && _currentSelectedPattern == null) ||
        _currentFeatureRoom == PerfectEffect.hairColor.name) {
      return Container(height: 50);
    }
    return FutureBuilder(
        future: patternList(context),
        builder: (BuildContext context, AsyncSnapshot<Widget> patternList) {
          return SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: patternList.data);
        });

  }

  Future<Widget> patternList(BuildContext context) async {
    List list = await skuHandler.getPatterns(_currentSelectedSku!, "");

    if (_currentSelectedPattern == null) {
      setState(() {
        _currentSelectedPattern = list[0]["guid"];
      });
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        // Safely cast the pattern data to Map<String, dynamic>
        var pattern = list[index];
        bool isSelected = _currentSelectedPattern == pattern?["guid"];

        return TextButton(
          onPressed: () {
            if (pattern != null) {
              setState(() {
                _currentSelectedPattern = pattern["guid"];
              });
              makeupCamViewChannel.apply(const VtoSetting().create(
                _currentSelectedProduct!,
                _currentSelectedSku!,
                pattern["guid"],
                "",
                "",
              ));
              // Add the pattern to the selected patterns list
              _addPatternToList(pattern);  // Pattern is now safely casted
            }
          },
          style: TextButton.styleFrom(minimumSize: const Size(50, 80)),
          child: FutureBuilder(
            future: patternCell(context, pattern , isSelected),
            builder: (BuildContext context, AsyncSnapshot<Widget> patternList) {
              return SizedBox(
                height: 45,
                width: 45,
                child: patternList.data,
              );
            },
          ),
        );
      },
    );
  }

  void _addPatternToList(Map pattern) {
    setState(() {
      selectedPatterns.add(pattern);  // Add the selected pattern to the list
    });
  }

  Future<Widget> patternCell(BuildContext context, Map pattern, bool isSelected) async {
    if (pattern == null || pattern["thumbnail"] == null || pattern["thumbnail"] == "") {
      return Container();
    }
    return Container(
      height: 20,
      width: 40,
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected ? Colors.red : Colors.transparent,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: _loadImage(pattern["thumbnail"], 40, BoxFit.cover),
    );
  }

  Widget selectedPatternsList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(8.0),
      itemCount: selectedPatterns.length,
      itemBuilder: (context, index) {
        // Safely cast the selected pattern to Map<String, dynamic>
        Map pattern = selectedPatterns[index] ;
        return ListTile(
          leading: _loadImage(pattern["thumbnail"], 40, BoxFit.cover),
          title: Text(pattern["name"] ?? "Unnamed Pattern"),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              _removePatternFromList(index); // Add function to remove pattern
            },
          ),
        );
      },
    );
  }



  Future<Widget> skuList(BuildContext context, String productGuid) async {
    List skus = await skuHandler.getSkus(productGuid);
    // Add clear button
    skus.insert(0, {});
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(0),
        itemCount: skus.length,
        itemBuilder: (context, index) {
          String? thumbnailUrl = null;
          String? name = null;
          switch (effectNameToPerfectEffect(_currentFeatureRoom!)) {
            case PerfectEffect.eyeshadow:
            case PerfectEffect.highlighter:
            case PerfectEffect.contour:
            case PerfectEffect.highlighterAndContour:
              thumbnailUrl = skus[index]['thumbnail'];
              name = skus[index]['name'];
              break;
            case PerfectEffect.eyewear:
            case PerfectEffect.eyewear3D:
            case PerfectEffect.background:
            case PerfectEffect.eyeColor:
              thumbnailUrl = skus[index]['thumbnail'];
              name = null;
              break;
            case PerfectEffect.earrings:
              thumbnailUrl = skus[index]['thumbnail'];
              name = index.toString().padLeft(2, '0');
              break;
            default:
              thumbnailUrl = null;
              name = null;
          }

          if (thumbnailUrl == null) {
            return TextButton(
                onPressed: () async {
                  setState(() {
                    _currentSelectedSkuIndex = index;
                    _currentSelectedSku = skus[index]['guid'];
                    _currentSelectedPattern = null;
                  });
                  if (index == 0) {
                    makeupCamViewChannel
                        .clear(effectNameToPerfectEffect(_currentFeatureRoom!));
                  } else {
                    makeupCamViewChannel.apply(const VtoSetting().create(
                        _currentSelectedProduct!,
                        skus[index]['guid'],
                        "",
                        "",
                        ""));
                  }
                },
                child: index == 0
                    ? const Icon(
                        Icons.not_interested,
                        color: Colors.white,
                        size: 45.0,
                      )
                    : FutureBuilder(
                        future: colorCell(context, skus[index],
                            _currentSelectedSkuIndex == index),
                        builder: (BuildContext context,
                            AsyncSnapshot<Widget> productList) {
                          return SizedBox(
                              height: 45, width: 45, child: productList.data);
                        }));
          } else {
            return TextButton(
                onPressed: () async {
                  setState(() {
                    _currentSelectedSkuIndex = index;
                    _currentSelectedSku = skus[index]['guid'];
                    _currentSelectedPattern = null;
                    _currentSelectedWearingStyle = null;
                  });
                  if (index == 0) {
                    makeupCamViewChannel
                        .clear(effectNameToPerfectEffect(_currentFeatureRoom!));
                  } else {
                    makeupCamViewChannel.apply(const VtoSetting().create(
                        _currentSelectedProduct!,
                        skus[index]['guid'],
                        "",
                        "",
                        ""));
                  }
                },
                child: Container(
                    height: 40,
                    width: 50,
                    padding: const EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _currentSelectedSku == skus[index]['guid']
                              ? Colors.red
                              : Colors.transparent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: skus[index]['thumbnail'] != ""
                        ? Column(children: [
                            _loadImage(skus[index]['thumbnail'],
                                name != null ? 25 : 40, BoxFit.cover),
                            if (name != null)
                              Text(name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                      height: 1))
                          ])
                        : const Icon(Icons.image)));
          }
        });
  }

  ListView featureList(BuildContext context) {
    List<String> features = ['Look'] +//9/9/969//969//
        List<String>.from(PerfectEffect.values.map((effect) => effect.name));
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        itemBuilder: (context, index) {
          return TextButton(
              onPressed: () {
                setState(() {
                  print("Selected feature: ${features[index]}");
                  print(features.length);
                  _currentFeatureRoom = features[index];
                  _currentSelectedProduct = null;
                  _currentSelectedSku = null;
                  _currentSelectedPattern = null;
                });
              },
              style: TextButton.styleFrom(minimumSize: const Size(100, 20)),
              child: Text(
                features[index],
                style: TextStyle(
                    color: _currentFeatureRoom == features[index]
                        ? Colors.pink
                        : Colors.white,
                    fontSize: 14),
              ));
        });
  }



  void _showSuccessSnackbar(String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(

      showSuccessDialog(successMessage),
    );
  }

  void _updateProgress(String progress) {
    setState(() {
      _progressValue = double.parse(progress);
    });
  }

  Widget _loadImage(String imagePath, double height, BoxFit fit) {
    if (imagePath.contains("http")) {
      return Image.network(imagePath, fit: fit, height: height);
    } else {
      if (imagePath.contains("file://")) {
        imagePath = imagePath.replaceAll("file://", "");
      }
      return Image.file(File(imagePath), fit: fit, height: height);
    }
  }

  // Callback function
  void onPlatformViewCreated(int id) {
    makeupCamViewChannel = MakeupCamViewChannel(id);
    print('onPlatformViewCreated to startCamera');
    makeupCamViewChannel.startCamera();
    makeupCamViewChannel.onError = onError;
    makeupCamViewChannel.onProgress = onProgress;

    skuHandler = SkuHandler();
    skuHandler.onError = onError;
    skuHandler.onProgress = onProgress;

    lookHandler = LookHandler();
    lookHandler.onError = onError;
    lookHandler.onProgress = onProgress;
  }

  void onProgress(String progress) {
    // The progress is from 0.0 to 1.0
    _updateProgress(progress);
  }

  void onError(String error) {
    if (kDebugMode) {
      print("Error: $error");
    }
    _showErrorSnackbar(error);
  }

  Positioned functionalButtons() {
    return Positioned(
        top: 86.0,
        left: 26.0,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          functionalButton('Sync SKU', Colors.pink, () {
            setState(() {
              _isShowProgress = true;

            });
            skuHandler.syncServer().then((isFinished) => {
                  setState(() {
                    _isShowProgress = false;
                  })
                });
          }),
          functionalButton('Clear SKU', Colors.red, () {
            skuHandler.clear();
          }),
          functionalButton('Sync Look', Colors.green, () {
            lookHandler.syncServer();
          }),
          functionalButton('Clear Look', Colors.lightGreen, () {
            lookHandler.clear();
          }),
        ]));
  }

  Widget makeupCamView(BuildContext context) {
    const String viewType = 'makeupCam_view';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'width': MediaQuery.of(context).size.width,
      'height': MediaQuery.of(context).size.height,
    };
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PlatformViewLink(
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <Factory<
                    OneSequenceGestureRecognizer>>{},
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
            viewType: viewType);
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
        );
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }

  Future<Widget> intensitiesSlider() async {
    if (_currentFeatureRoom != "SkinSmooth") {
      return Container();
    }

    if (_intensityValues.isEmpty) {
      await makeupCamViewChannel.getIntensities().then((value) => {
            setState(() {
              _intensityValues = value;
              print("Intensities: $_intensityValues");
            })
          });
    }

    return Positioned(
        top: 50,
        right: 20,
        height: 250,
        child: RotatedBox(
          quarterTurns: 3, // Rotate the slider 90 degrees clockwise
          child: Slider(
            value: _intensityValues['SkinSmooth'].first / 100,
            onChanged: (value) {
              setState(() {
                var intensity = value * 100;
                _intensityValues['SkinSmooth'] = [intensity];
              });
              makeupCamViewChannel
                  .setIntensities({"intensities": _intensityValues});
            },
            min: 0.0,
            max: 1.0,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Stack(
          children: [
            if (perfectLibInited) Center(child: makeupCamView(context)),
            controlPanel(context),
            functionalButtons(),
            backButton(context),
            FutureBuilder(
                future: intensitiesSlider(),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> intensityList) {
                  return Container(child: intensityList.data);
                }),
            if (_isLoading) loadingIndicator(),
            if (_isShowProgress) progressIndicator(_progressValue),
          //  _buildSelectedPatternsList(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    skuHandler.dispose();
    lookHandler.dispose();
    makeupCamViewChannel.dispose();
    perfectLibChannel.unload();
    super.dispose();
  }
}
*/
