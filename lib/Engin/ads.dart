import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../Engin/report_screen.dart';
import '../Engin/skincare.dart';
import '../contstants.dart';

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
  int _currentAdIndex = 0;

  List<Map<String, dynamic>> _ads = [];

  @override
  void initState() {
    super.initState();
    _fetchAdData();
  }

  Future<void> _fetchAdData() async {
    final url = Uri.parse('https://gomla.egymetrix.net/wp-json/skinad/v1/slots');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final slots = List<Map<String, dynamic>>.from(data['slots']);

        final now = DateTime.now();
        print("📦 Total slots fetched: ${slots.length}");
        print("🕒 Current time: $now\n");

        final filteredSlots = slots.where((slot) {
          final now = DateTime.now();

          final startDate = DateTime.parse(slot['start_date']);
          final endDate = DateTime.parse(slot['end_date']);

          final isDateInRange = now.isAfter(startDate) && now.isBefore(endDate.add(const Duration(days: 1)));

          // Time range filtering
          final fromTimeParts = slot['from_time'].split(':');
          final toTimeParts = slot['to_time'].split(':');

          final fromTime = TimeOfDay(hour: int.parse(fromTimeParts[0]), minute: int.parse(fromTimeParts[1]));
          final toTime = TimeOfDay(hour: int.parse(toTimeParts[0]), minute: int.parse(toTimeParts[1]));
          final currentTime = TimeOfDay.fromDateTime(now);

          bool isTimeInRange = _isTimeInRange(currentTime, fromTime, toTime);

          print('🔍 Slot: ${slot['name']}');
          print('📅 Date OK: $isDateInRange | 🕒 Time OK: $isTimeInRange');

          return isDateInRange && isTimeInRange;
        }).toList();

        _ads = widget.isbeforetest
            ? filteredSlots.where((slot) => slot['Ad_before'] == 'test').toList()
            : filteredSlots.where((slot) => slot['Ad_before'] == 'result').toList();

        if (_ads.isNotEmpty) {
          _loadNextAd();
        } else {
          print("🚫 No valid ads found — navigating...");
          _navigateToNextPage();
        }
      } else {
        print("❌ Failed to fetch data: ${response.statusCode}");
      }
    } catch (error) {
      print("❌ Error fetching ads: $error");
    }
  }
  bool _isTimeInRange(TimeOfDay now, TimeOfDay start, TimeOfDay end) {
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (endMinutes >= startMinutes) {
      // Normal range (same day)
      return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    } else {
      // Range that passes midnight (e.g., 23:00 - 02:00)
      return nowMinutes >= startMinutes || nowMinutes <= endMinutes;
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
        _mediaUrl = mediaUrl;
        _mediaType = mediaType;
        _skipTime = skipTime;
        _remainingTime = skipTime;
        _externalLink = externalLink;
        _isSkippable = false;
      });

      if (_mediaType == 'video') {
        _initializeVideoController();
      } else if (_mediaType == 'image') {
        _startTimer();
      }

      _currentAdIndex++; // Prepare for next ad
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

  String _getDirectDownloadLink(String link) {
    final RegExp regExp = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(link);
    if (match != null && match.groupCount >= 1) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return link;
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
          print("❌ Video error: $error");
          setState(() {
            _mediaType = 'image';
            _mediaUrl = 'https://example.com/fallback.jpg';
            _startTimer();
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

    if (_videoController.value.position >= _videoController.value.duration) {
      _videoController.removeListener(_handlePlaybackState);
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
          // DO NOT navigate here — let video finish naturally
        }
      });
    });
  }

  void _skipAd() {
    _timer?.cancel();
    if (_mediaType == 'video' && _videoController.value.isInitialized) {
      _videoController.pause();
    }

    // 👇 Check if more ads exist
    if (_currentAdIndex < _ads.length) {
      _loadNextAd(); // Show next ad
    } else {
      _navigateToNextPage(); // No more ads → navigate
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_mediaType == 'video' && _videoController.value.isInitialized) {
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
          if (_mediaType == 'video' && _videoController.value.isInitialized)
            GestureDetector(
              onTap: () => setState(() => _showPauseButton = !_showPauseButton),
              child: SizedBox.expand(child: VideoPlayer(_videoController)),
            )
          else if (_mediaType == 'image' && _mediaUrl != null)
            GestureDetector(
              onTap: () => setState(() => _showPauseButton = !_showPauseButton),
              child: Image.network(
                _mediaUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else
            Center(
              child: CircularProgressIndicator(color: mainColor),
            ),

          if (_mediaType == 'video' && _videoController.value.isInitialized)
            Positioned(
              top: 30,
              left: 10,
              child: IconButton(
                icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.black),
                onPressed: _toggleMute,
              ),
            ),

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
                child:  Text(AppLocalizations.of(context)!.skipAd, style: const TextStyle(fontSize: 16)),
              ),
            ),

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
                child: Text("$_remainingTime",
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                  onPressed: () => _openURL(_externalLink ?? ""),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  child: Text(AppLocalizations.of(context)!.get),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openURL(String url) async {
    if (url.isNotEmpty && await canLaunch(url)) {
      await launch(url);
    } else {
      print("❌ Could not launch $url");
    }
  }
}
