import 'dart:io';
import 'package:Gomla/Engin/skincare.dart';
import 'package:Gomla/contstants.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

class PDFViewerPage extends StatefulWidget {
  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? _pdfPath;
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
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/downloaded.pdf';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete(); // ✅ حذف أي ملف قديم
      }

      // 🔥 تحميل الملف من الرابط
      final response = await http.get(Uri.parse(
          'https://gomla.sa/skin-analysis/gomla-skin-analysis-disclaimer-en.pdf'));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        if (await file.exists()) {
          int fileSize = await file.length();
          print("✅ PDF size: $fileSize bytes");

          if (fileSize == 0) {
            setState(() {
              _loading = false;
              _errorMessage = '❌ PDF file is empty.';
            });
            return;
          }

          // ✅ تحميل الملف والتحقق من عدد الصفحات
          final document = await PdfDocument.openFile(file.path);
          int pageCount = document.pagesCount;

          if (pageCount > 0) {
            setState(() {
              _pdfPath = file.path;
              _loading = false;
              _initializePdfController(document); // ✅ التهيئة بعد التأكد من الملف
            });
          } else {
            setState(() {
              _loading = false;
              _errorMessage = '❌ PDF file is empty or corrupted.';
            });
          }
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
        _errorMessage = '❌ Error downloading PDF: $e';
      });
    }
  }

  void _initializePdfController(PdfDocument document) {
    setState(() {
      _pdfController = PdfControllerPinch(
        document: Future.value(document), // ✅ تحويل PdfDocument إلى Future<PdfDocument>
        initialPage: 0, // ✅ عرض من الصفحة الأولى
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: Text(''),
        backgroundColor:  mainColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pushReplacement  (context, MaterialPageRoute(builder: (context) => const SkincareDetect())),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : _pdfController != null
          ? PdfViewPinch(
        controller: _pdfController!,
        scrollDirection: Axis.vertical, // ✅ تمرير عمودي
        padding: 5.0, // ✅ ضبط الهوامش
      )
          : const Center(child: Text("❌ No PDF available")),
    );
  }

  @override
  void dispose() {
    _pdfController?.dispose(); // ✅ تنظيف الذاكرة عند الخروج
    super.dispose();
  }
}
