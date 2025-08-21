import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:precious/utils/config.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class PDFBookView extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFBookView({super.key, required this.pdfUrl, required this.title});

  @override
  // ignore: library_private_types_in_public_api
  _PDFBookViewState createState() => _PDFBookViewState();
}

class _PDFBookViewState extends State<PDFBookView> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await Dio().get(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/downloaded.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.data);
      setState(() {
        pdfPath = filePath;
      });
    } catch (e) {
      print("Error downloading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Config.whiteColor,
        foregroundColor: Config.primaryColor,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: "Raleway-Regular",
            fontSize: 15.0,
            color: Config.darkColor,
          ),
        ),
        toolbarHeight: 45,
      ),
      body: pdfPath != null
          ? PDFView(
              filePath: pdfPath,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageSnap: true,
              onPageChanged: (page, total) {
                Text('Page $page of $total');
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
