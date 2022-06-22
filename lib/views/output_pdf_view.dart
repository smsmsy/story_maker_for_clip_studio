
import 'dart:io';

import 'package:flutter/foundation.dart'; // for kDebugMode
import 'package:flutter/material.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';

// for download pdf file
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';


// なんかこいつ怪しいが・・・
// rootBundle用に入れたけどいらないかも
// import 'package:flutter/services.dart';


class PreviewPDFPage extends StatefulWidget {
  final List<dynamic> contents;

  const PreviewPDFPage(this.contents, {Key? key}) : super(key: key);

  @override
  State<PreviewPDFPage> createState() => _PreviewPDFPageState();
}

class _PreviewPDFPageState extends State<PreviewPDFPage> with SingleTickerProviderStateMixin {
  PrintingInfo? printingInfo;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _init() async {
    final info = await Printing.info();

    setState(() {
      printingInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: _saveAsFile,
        )
    ];

    return Scaffold(
      body: Center(
        child: PdfPreview(
          maxPageWidth: 600,
          allowPrinting: true,
          allowSharing: true,
          canChangeOrientation: true,
          canChangePageFormat: false,
          canDebug: false,
          loadingWidget: const LinearProgressIndicator(),
          build: (PdfPageFormat format) async {
            final pdf = await PdfCreator.create();
            return await pdf.save();
          },
          actions: actions,
          onPrinted: _showPrintedToast,
          onShared: _showSharedToast,
        ),
      ),
    );
  }

  void _showPrintedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document printed successfully'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document shared successfully'),
      ),
    );
  }

  Future<void> _saveAsFile(
      BuildContext context,
      LayoutCallback build,
      PdfPageFormat pageFormat,
      ) async {
    final bytes = await build(pageFormat);

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File(appDocPath + '/' + 'document.pdf');
    if (kDebugMode) {
      print('Save as file ${file.path} ...');
    }
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }
}

class PdfCreator {
  static Future<pw.Document> create() async {
    // フォントの読み込みとオブジェクト化
    final font = await PdfGoogleFonts.shipporiMinchoRegular();
    // final fontData = await rootBundle.load("源柔ゴシックＰ");
    // final font = pw.Font.ttf(fontData);

    final pdf = pw.Document(author: 'Me');

    final cover = pw.Page(
      pageTheme: pw.PageTheme(
        theme: pw.ThemeData.withFont(base: font),
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        buildBackground: (context) => pw.Opacity(
          opacity: 0.3,
          child: pw.FlutterLogo(),
        ),
      ),
      build: (context) => _buildPage(),
    );

    pdf.addPage(cover);

    return pdf;
  }

  static _buildPage() {
    return pw.Center(
      child: pw.Column(
        children: <pw.Widget> [
          pw.Text('test page'),
        ],
      ),
    );
  }
}