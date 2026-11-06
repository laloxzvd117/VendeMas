import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/format.dart';
import '../../domain/reports.dart';
import '../../providers.dart';
import 'report_bodies.dart';
import 'report_texts.dart';

enum ExportFormat { pdf, csv, image }

class _ExportError implements Exception {
  const _ExportError(this.message);
  final String message;
  @override
  String toString() => message;
}

/// F-19: elegir el formato y compartir el resumen semanal con el menú de
/// compartir del dispositivo (RF-20).
Future<void> showExportSheet(BuildContext context, WidgetRef ref) async {
  final choice = await showModalBottomSheet<ExportFormat>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _ExportSheet(),
  );
  if (choice == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await _export(ref, choice);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('No se pudo exportar: $e')));
  }
}

class _ExportSheet extends StatelessWidget {
  const _ExportSheet();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Exportar resumen', style: tt.headlineSmall),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('PDF'),
              subtitle: const Text('Para imprimir o mandar por mensaje.'),
              onTap: () => Navigator.of(context).pop(ExportFormat.pdf),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('CSV'),
              subtitle: const Text('Para abrirlo en Excel u otra hoja de cálculo.'),
              onTap: () => Navigator.of(context).pop(ExportFormat.csv),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Imagen'),
              subtitle: const Text('Una foto del resumen para compartir.'),
              onTap: () => Navigator.of(context).pop(ExportFormat.image),
            ),
          ],
        ),
      ),
    );
  }
}

String _ymd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _plain(String s) => s.replaceAll(' ', ' ');

String _decimal(int cents) => (cents / 100).toStringAsFixed(2);

/// CSV con una fila por día. Lleva BOM para que Excel respete los acentos.
String weekCsv(WeekSummary w) {
  final b = StringBuffer('﻿')
    ..writeln('Fecha,Día,Ventas,Ganancia,Número de ventas');
  for (final day in w.days) {
    b.writeln('${_ymd(day.day)},${dayShort[day.day.weekday - 1]},'
        '${_decimal(day.sales)},${_decimal(day.profit)},${day.tickets}');
  }
  b.writeln('Total,,${_decimal(w.sales)},${_decimal(w.profit)},${w.tickets}');
  return b.toString();
}

Future<Uint8List> _weekPdf(String business, WeekSummary w) async {
  final doc = pw.Document();
  pw.Widget cell(String t, {bool bold = false, pw.Alignment? align}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Align(
          alignment: align ?? pw.Alignment.centerLeft,
          child: pw.Text(t,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ),
      );
  final right = pw.Alignment.centerRight;

  doc.addPage(
    pw.Page(
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$business - Resumen semanal',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(weekLabel(w)),
          pw.SizedBox(height: 16),
          pw.Text('Vendido: ${_plain(money(w.sales))}'),
          pw.Text('Ganancia: ${_plain(money(w.profit))}'),
          pw.Text('Ventas registradas: ${w.tickets}'),
          if (w.percent != null)
            pw.Text('Contra la semana anterior: ${signed(w.percent!)}'),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(children: [
                cell('Día', bold: true),
                cell('Ventas', bold: true, align: right),
                cell('Ganancia', bold: true, align: right),
                cell('No. de ventas', bold: true, align: right),
              ]),
              for (final day in w.days)
                pw.TableRow(children: [
                  cell('${dayShort[day.day.weekday - 1]} ${day.day.day}'),
                  cell(_plain(money(day.sales)), align: right),
                  cell(_plain(money(day.profit)), align: right),
                  cell('${day.tickets}', align: right),
                ]),
            ],
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

Future<Uint8List> _captureWeek() async {
  final boundary =
      weekCaptureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw const _ExportError('abre el resumen semanal e inténtalo de nuevo.');
  }
  final image = await boundary.toImage(pixelRatio: 2.5);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) throw const _ExportError('no se pudo generar la imagen.');
  return data.buffer.asUint8List();
}

Future<void> _export(WidgetRef ref, ExportFormat format) async {
  final d = ref.read(reportDataProvider).value;
  if (d == null) throw const _ExportError('todavía no hay datos.');
  final weeks = lastWeeks(d);
  final sel = ref.read(selectedWeekProvider);
  final w = weeks[sel < 0 ? 0 : (sel >= weeks.length ? weeks.length - 1 : sel)];
  final business = ref.read(businessNameProvider).value ?? 'VendeMas';

  final dir = await getTemporaryDirectory();
  final base = 'VendeMas_semana_${_ymd(w.start)}';
  final File file;
  final String mime;
  switch (format) {
    case ExportFormat.pdf:
      file = File('${dir.path}/$base.pdf');
      await file.writeAsBytes(await _weekPdf(business, w));
      mime = 'application/pdf';
    case ExportFormat.csv:
      file = File('${dir.path}/$base.csv');
      await file.writeAsString(weekCsv(w));
      mime = 'text/csv';
    case ExportFormat.image:
      file = File('${dir.path}/$base.png');
      await file.writeAsBytes(await _captureWeek());
      mime = 'image/png';
  }

  await SharePlus.instance.share(ShareParams(
    files: [XFile(file.path, mimeType: mime)],
    subject: '$business - ${weekLabel(w)}',
    text: '$business: ${weekLabel(w)}',
  ));
}
