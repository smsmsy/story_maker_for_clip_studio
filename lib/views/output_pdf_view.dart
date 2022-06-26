
import 'dart:io';

import 'package:flutter/foundation.dart'; // for kDebugMode
import 'package:flutter/material.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';

// for download pdf file
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:story_maker_for_clip_studio/classes/content_class.dart' as cc;

import 'package:flutter/services.dart';


class PreviewPDFPage extends StatefulWidget {
  final List<dynamic> contents;
  final String title;

  const PreviewPDFPage(this.title, this.contents, {Key? key}) : super(key: key);

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
            final pdf = await PdfCreator.create(widget.title, widget.contents);
            return await pdf.save();
          },
          actions: actions,
          onPrinted: _showPrintedToast,
          onShared: _showSharedToast,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back_ios_new),
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
  static Future<pw.Document> create(String title, List<dynamic> contents) async {
    // フォントの読み込みとオブジェクト化
    // final font = await PdfGoogleFonts.shipporiMinchoRegular();
    final fontData = await rootBundle.load("assets/fonts/GenJyuuGothic-P-Regular.ttf");
    final font = pw.Font.ttf(fontData);

    final pdf = pw.Document(author: 'Me');

    final cover = pw.MultiPage(
      pageTheme: pw.PageTheme(
        theme: pw.ThemeData.withFont(base: font),
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        buildBackground: (context) => pw.Opacity(
          opacity: 0.3,
          child: pw.FlutterLogo(),
        ),
      ),
      header: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
          padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey),
            ),
          ),
          child: pw.Text(
            title,
            style: pw.Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
          ),
        );
      },
      build: (context) => [_buildPDFPage(contents)],
    );

    pdf.addPage(cover);

    return pdf;
  }

  static _buildPDFPage(List<dynamic> contents) {
    return pw.Center(
      child: pw.Column(
        children: <pw.Widget> [
          pw.Table(
            children: List.generate(
              contents.length, (index) => pw.TableRow(
              children: <pw.Widget> [_buildPDFTableRow(index, contents),],),
            ),
          ),
        ],
      ),
    );
  }

  static _buildPDFTableRow(int index, List<dynamic> contents) {
    return pw.Container(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          if(contents[index] is Divider)
            pw.Row(
              children: [
                pw.Expanded(child: pw.Divider(),),
                pw.Text("${currentPageNum(index, contents)} / ${totalPageNum(contents)}"),
                pw.Expanded(child: pw.Divider(),),
              ],
            ),
          if(contents[index] is! Divider)
            if(contents[index].contentType != cc.ContentType.memo)
              if(contents[index].contentType == cc.ContentType.serif)
                pw.Row(
                  children: [
                    // 名前
                    pw.Text(
                      contents[index].person.name,
                      style: pw.TextStyle(
                        color: PdfColor.fromInt(contents[index].person.color.value),
                      ),
                    ),
                    // Icon
                    // pw.Text(),
                    pw.SizedBox(width: 20.0),
                    // 内容
                    pw.Text(" 「 ${contents[index].line} 」"),
                  ],
                ),
          if(contents[index] is! Divider)
            if(contents[index].contentType != cc.ContentType.memo)
              if(contents[index].contentType == cc.ContentType.mood)
                pw.Row(
                  children: [
                    // 名前
                    pw.Text(
                      contents[index].person.name,
                      style: pw.TextStyle(
                        color: PdfColor.fromInt(contents[index].person.color.value),
                      ),
                    ),
                    // Icon
                    // pw.Text(),
                    pw.SizedBox(width: 20.0),
                    // 内容
                    pw.Text(" ( ${contents[index].line} ) "),
                  ],
                ),
          if(contents[index] is! Divider)
            if(contents[index].contentType == cc.ContentType.memo)
              pw.Text(
                contents[index].line,
                style: pw.TextStyle(
                  color: PdfColor.fromInt(contents[index].person.color.value),
                ),
              ),
        ],
      ),
    );
  }

  static int currentPageNum(int index, List<dynamic> contents){
    int count = 1;
    for(int i = 0; i < index; i++){
      if(contents[i] is Divider) count;
    }
    return count;
  }

  static int totalPageNum(List<dynamic> contents){
    int count = 0;
    for(int i = 0; i < contents.length; i++){
      if(contents[i] is Divider) count;
    }
    return count;
  }


}