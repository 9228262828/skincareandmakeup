import 'dart:async';
import 'dart:convert';

import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../Engin/report_screen.dart';
import '../Engin/skincare.dart';

class AdPage extends StatefulWidget {
  final bool isbeforetest;
  final List<Map<String, dynamic>> capturedFeatures;
  final Map<String, String> reports;
  final Map<String, dynamic> skinAnalysisData;
  final Map<String, dynamic> scores;

  const AdPage({
    super.key,
    required this.isbeforetest,
    required this.capturedFeatures,
    required this.reports,
    required this.skinAnalysisData,
    required this.scores,
  });

  @override
  _AdPageState createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> {
  late VideoPlayerController _videoController;
  Timer? _timer;

  int _remainingTime = 0;
  bool _isSkippable = false;
  bool _isMuted = false;
  bool _showPauseButton = false;

  String? _mediaUrl;
  String? _externalLink;
  String? _mediaType;
  int? _skipTime;
  bool _isAfterTest = false;
  int _currentAdIndex = 0;

  List<Map<String, dynamic>> _ads = [];

  @override
  void initState() {
    super.initState();
    _fetchAdData();
  }

  Future<void> _fetchAdData() async {
    final url = Uri.parse('https://gomla.sa/wp-json/skinad/v1/slots');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final slots = List<Map<String, dynamic>>.from(data['slots']);

        if (slots.isNotEmpty) {
          // Filter ads based on `widget.isbeforetest` condition
          if (widget.isbeforetest) {
            // Show only ads before the test (Ad_before == 'test')
            _ads = slots.where((slot) => slot['Ad_before'] == 'test').toList();
          } else {
            // Show ads after the test (Ad_before == 'result')
            _ads = slots.where((slot) => slot['Ad_before'] == 'result').toList();
          }

          if (_ads.isNotEmpty) {
            _loadNextAd(); // Load the first ad
          } else {
               _navigateToNextPage();
          }
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  void _loadNextAd() {
    if (_currentAdIndex < _ads.length) {
      final ad = _ads[_currentAdIndex];
      final mediaUrl = _getDirectDownloadLink(ad['media_url']);
      final mediaType = ad['media_type'];
      final skipTime = int.parse(ad['skip_time']);
      final externalLink = ad['external_link'];

      setState(() {
        // Reset and update variables for new ad
        _mediaUrl = mediaUrl;
        _mediaType = mediaType;
        _skipTime = skipTime;
        _remainingTime = skipTime;
        _externalLink = externalLink;
        _isSkippable = false; // Reset skip flag
      });

      if (_mediaType == 'video') {
        _initializeVideoController();
      } else if (_mediaType == 'image') {
        _startTimer();
      }

      _currentAdIndex++;
    } else {
        _navigateToNextPage();
    }
  }

  void _navigateToNextPage() {
    _timer?.cancel();

    if (_mediaType == 'video' && _videoController.value.isInitialized) {
      _videoController.pause();
    }

    widget.isbeforetest
        ? Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SkincareDetect()),
    )
        : Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(
          capturedFeatures: widget.capturedFeatures,
          reports: widget.reports,
          skinAnalysisData: widget.skinAnalysisData,
                score: widget.scores,
              ),
      ),
    );
  }

  String _getDirectDownloadLink(String googleDriveLink) {
    final RegExp regExp = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(googleDriveLink);
    if (match != null && match.groupCount >= 1) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return googleDriveLink;
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _initializeVideoController() {
    if (_mediaUrl != null) {
      _videoController = VideoPlayerController.network(_mediaUrl!)
        ..initialize().then((_) {
          setState(() {});
          _videoController.addListener(_handlePlaybackState);
          _videoController.play();
        }).catchError((error) {
          print("Video initialization error: $error");
          setState(() {
            _mediaType = 'image';
            _mediaUrl = 'https://example.com/fallback-image.jpg';
          });
        });
    }
  }

  void _handlePlaybackState() {
    if (_videoController.value.isInitialized &&
        _videoController.value.isPlaying &&
        (_timer == null || !_timer!.isActive)) {
      _startTimer();
    }

    if (_videoController.value.isInitialized &&
        _videoController.value.position >= _videoController.value.duration) {
      _loadNextAd();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        }
        if (_remainingTime == 0) {
          _isSkippable = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _skipAd() {
    _loadNextAd();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_videoController.value.isInitialized) {
      _videoController.removeListener(_handlePlaybackState);
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Media content (video or image)
          if (_mediaType == 'video' && _videoController.value.isInitialized)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showPauseButton = !_showPauseButton;
                });
              },
              child: SizedBox.expand(
                child: VideoPlayer(_videoController),
              ),
            )
          else if (_mediaType == 'image' && _mediaUrl != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showPauseButton = !_showPauseButton;
                });
              },
              child: Image.network(
                _mediaUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
          // Mute button
          if (_mediaType == 'video' && _videoController.value.isInitialized)
            Positioned(
              top: 30,
              left: 10,
              child: IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.black,
                ),
                onPressed: _toggleMute,
              ),
            ),
          // Skip button
          if (_isSkippable)
            Positioned(
              top: 40,
              right: 20,
              child: ElevatedButton(
                onPressed: _skipAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.7),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Skip Ad"),
              ),
            ),
          // Countdown timer
          if (!_isSkippable)
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  "$_remainingTime",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,

            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _openURL(_externalLink!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 10,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.get),
                ),
              ),
            ),
          ),
          // Download button
         /* Positioned(
            bottom: 40,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              width: mediaQueryWidth(context) * 0.9,
              height: mediaQueryHeight(context) * 0.15,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: mediaQueryWidth(context) * 0.25,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                       ),
                  ),
                ],
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  // Open an external URL (for example, external link in the ad)
  Future<void> _openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }
}
