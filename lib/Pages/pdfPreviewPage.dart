import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:stunde/Mixins/pdfReport.dart';

class PdfPreviewPage extends StatefulWidget {
  static const routeName = '/previewreport';
  @override
  _PdfPreviewPageState createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  Widget build(BuildContext bc) {
    return Scaffold(
      appBar: AppBar(),
      body: PDFView(
        filePath: (ModalRoute.of(context)!.settings.arguments as PdfReport)
            .filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onRender: (_pages) {
          print('pagina $_pages');
          setState(() {});
        },
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController pdfViewController) {
         // _controller.complete(pdfViewController);
        },
      ),
    );
  }
}
