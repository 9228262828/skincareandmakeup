import 'dart:io';
import 'package:Gomla/Engin/skincare.dart';
import 'package:Gomla/contstants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PDFViewerPage extends StatefulWidget {
  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  bool _loading = true;
  String? _errorMessage;
  PdfControllerPinch? _pdfController;

  @override
  void initState() {
    super.initState();
    _loadPdfFromUrl();
  }

  Future<void> _loadPdfFromUrl() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? language = prefs.getString('locale') ?? 'ar';

      String pdfUrl;
      if (language == 'ar') {
        pdfUrl = 'https://gomla.sa/wp-content/uploads/2025/04/gomla-skin-analysis-disclaimer-ar.pdf';
      } else {
        pdfUrl = 'https://gomla.sa/wp-content/uploads/2025/04/gomla-skin-analysis-disclaimer-en.pdf'; // Example for non-Arabic language (change URL as needed)
      }

      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        // ✅ Convert the response bytes directly into the PDF document
        final document = await PdfDocument.openData(response.bodyBytes);
        int pageCount = document.pagesCount;

        if (pageCount > 0) {
          setState(() {
            _loading = false;
            _initializePdfController(document); // ✅ Initialize the PDF controller
          });
        } else {
          setState(() {
            _loading = false;
            _errorMessage = '❌ PDF file is empty or corrupted.';
          });
        }
      } else {
        setState(() {
          _loading = false;
          _errorMessage = '❌ Failed to download PDF.';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = '❌ Error loading PDF: $e';
      });
    }
  }

  void _initializePdfController(PdfDocument document) {
    setState(() {
      _pdfController = PdfControllerPinch(
        document: Future.value(document), // ✅ Convert PdfDocument to Future<PdfDocument>
        initialPage: 0, // ✅ Show from the first page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: mainColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const SkincareDetect()),
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage != null
          ? Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red),
        ),
      )
          : _pdfController != null
          ? PdfViewPinch(
        controller: _pdfController!,
        scrollDirection: Axis.vertical, // ✅ Vertical scroll
        padding: 5.0, // ✅ Set the padding
      )
          : Center(child: Text("❌ No PDF available")),
    );
  }

  @override
  void dispose() {
    _pdfController?.dispose(); // ✅ Clean up the memory when exiting
    super.dispose();
  }
}
