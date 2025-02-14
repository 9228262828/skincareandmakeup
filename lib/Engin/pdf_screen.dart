import 'dart:io';
import 'package:Gomla/Engin/skincare.dart';
import 'package:Gomla/contstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PDFViewerPage extends StatefulWidget {
  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? _pdfPath;



  @override
  void initState() {
    super.initState();

    _loadPdfFromUrl();
  }

  // Function to download PDF from a URL and save it to the device
  Future<void> _loadPdfFromUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('locale') ;
    try {
      final response = await http.get(Uri.parse(
        language == 'en' ? 'https://gomla.sa/skin-analysis/gomla-skin-analysis-disclaimer-en.pdf' : 'https://gomla.sa/skin-analysis/gomla-skin-analysis-disclaimer-ar.pdf',
      ));

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/downloaded.pdf';
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _pdfPath = filePath;
        });
        print("PDF saved at: $filePath");
      } else {
        print('Failed to download PDF. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor:  mainColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pushReplacement  (context, MaterialPageRoute(builder: (context) => const SkincareDetect())),
        ),
      ),
      body: _pdfPath == null
          ? Center(child: CircularProgressIndicator(color:mainColor))
          : PDFView(
        filePath: _pdfPath,
      ),
    );
  }
}
