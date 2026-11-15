import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/format.dart';
import '../../core/platform.dart';
import '../../domain/reports.dart';
import '../../providers.dart';
import 'report_bodies.dart';
import 'report_texts.dart';
import 'week_share_card.dart';

enum ExportFormat { pdf, csv, image }

class _ExportError implements Exception {
  const _ExportError(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Semana elegida en el resumen y sus datos.
class _WeekExport {
  const _WeekExport(this.business, this.week, this.top);
  final String business;
  final WeekSummary week;
  final List<ProductStat> top;

  String get baseName => 'VendeMas_semana_${_ymd(week.start)}';
}

_WeekExport _current(WidgetRef ref) {
  final d = ref.read(reportDataProvider).value;
  if (d == null || !d.hasSales) throw const _ExportError('todavía no hay ventas.');
  final weeks = lastWeeks(d);
  final sel = ref.read(selectedWeekProvider).clamp(0, weeks.length - 1);
  final w = weeks[sel];
  return _WeekExport(ref.read(businessNameProvider).value ?? 'Mi negocio', w,
      weekProducts(d, w.start));
}

/// F-19: elegir el formato y compartir el resumen semanal (RF-20). En la
/// computadora el archivo se guarda en Descargas.
Future<void> showExportSheet(BuildContext context, WidgetRef ref) async {
  final choice = await showModalBottomSheet<ExportFormat>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _ExportSheet(),
  );
  if (choice == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final data = _current(ref);
    final File file;
    switch (choice) {
      case ExportFormat.pdf:
        file = await _write('${data.baseName}.pdf', await weekPdf(data.business, data.week, data.top));
      case ExportFormat.csv:
        file = await _writeText('${data.baseName}.csv',
            weekCsv(data.week, business: data.business, top: data.top));
      case ExportFormat.image:
        final bytes = await _previewImage(context, data);
        if (bytes == null) return;
        file = await _write('${data.baseName}.png', bytes);
    }
    if (isDesktop) {
      messenger.showSnackBar(SnackBar(
        duration: const Duration(seconds: 6),
        content: Text('Guardado en ${file.path}'),
      ));
      return;
    }
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: _mime(choice))],
      subject: '${data.business} - ${weekLabel(data.week)}',
      text: '${data.business}: ${weekLabel(data.week)}',
    ));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('No se pudo exportar: $e')));
  }
}

String _mime(ExportFormat f) => switch (f) {
      ExportFormat.pdf => 'application/pdf',
      ExportFormat.csv => 'text/csv',
      ExportFormat.image => 'image/png',
    };

Future<Directory> _targetDir() async {
  if (isDesktop) {
    return await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  }
  return getTemporaryDirectory();
}

Future<File> _write(String name, Uint8List bytes) async =>
    File('${(await _targetDir()).path}/$name').writeAsBytes(bytes);

Future<File> _writeText(String name, String text) async =>
    File('${(await _targetDir()).path}/$name').writeAsString(text);

class _ExportSheet extends StatelessWidget {
  const _ExportSheet();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final where = isDesktop ? ' Se guarda en Descargas.' : '';
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
              subtitle: Text('Reporte completo para imprimir o mandar.$where'),
              onTap: () => Navigator.of(context).pop(ExportFormat.pdf),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('CSV'),
              subtitle: Text('Para abrirlo en Excel u otra hoja de cálculo.$where'),
              onTap: () => Navigator.of(context).pop(ExportFormat.csv),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Imagen'),
              subtitle: Text('Una tarjeta con lo principal de la semana.$where'),
              onTap: () => Navigator.of(context).pop(ExportFormat.image),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Imagen ─────────────────────────

Future<Uint8List?> _previewImage(BuildContext context, _WeekExport data) {
  final key = GlobalKey();
  return showDialog<Uint8List>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RepaintBoundary(
                  key: key,
                  child: WeekShareCard(
                      business: data.business, week: data.week, top: data.top),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: Icon(isDesktop ? Icons.download_outlined : Icons.share_outlined),
                  label: Text(isDesktop ? 'Guardar' : 'Compartir'),
                  onPressed: () async {
                    final bytes = await _capture(key);
                    if (ctx.mounted) Navigator.pop(ctx, bytes);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<Uint8List> _capture(GlobalKey key) async {
  final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) throw const _ExportError('no se pudo generar la imagen.');
  final image = await boundary.toImage(pixelRatio: 3);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) throw const _ExportError('no se pudo generar la imagen.');
  return data.buffer.asUint8List();
}

// ───────────────────────── CSV ─────────────────────────

String _ymd(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _decimal(int cents) => (cents / 100).toStringAsFixed(2);

String _cell(String s) =>
    s.contains(RegExp(r'[,"\n]')) ? '"${s.replaceAll('"', '""')}"' : s;

/// CSV del resumen: datos de la semana, una fila por día con el total y los
/// productos de la semana. Lleva BOM para que Excel respete los acentos.
String weekCsv(WeekSummary w,
    {String business = '', List<ProductStat> top = const []}) {
  final b = StringBuffer('﻿');
  void row(List<String> cells) => b.writeln(cells.map(_cell).join(','));
  String avg(int sales, int tickets) =>
      tickets == 0 ? '0.00' : _decimal((sales / tickets).round());

  row(['Resumen semanal']);
  if (business.isNotEmpty) row(['Negocio', business]);
  row(['Semana', weekLabel(w)]);
  b.writeln();
  row(['Fecha', 'Día', 'Ventas', 'Ganancia', 'Número de ventas', 'Venta promedio']);
  for (final day in w.days) {
    row([
      _ymd(day.day),
      dayShort[day.day.weekday - 1],
      _decimal(day.sales),
      _decimal(day.profit),
      '${day.tickets}',
      avg(day.sales, day.tickets),
    ]);
  }
  row(['Total', '', _decimal(w.sales), _decimal(w.profit), '${w.tickets}',
      avg(w.sales, w.tickets)]);
  if (top.isNotEmpty) {
    b.writeln();
    row(['Producto', 'Piezas', 'Ventas', 'Ganancia']);
    for (final p in top) {
      row([p.name, '${p.units}', _decimal(p.revenue), _decimal(p.profit)]);
    }
  }
  return b.toString();
}

// ───────────────────────── PDF ─────────────────────────

/// Helvetica del PDF no trae el espacio fino que usa el formato de moneda.
String _plain(String s) => s.replaceAll(' ', ' ').replaceAll(' ', ' ');

Future<Uint8List> weekPdf(String business, WeekSummary w, List<ProductStat> top,
    {DateTime? now}) async {
  final brand = PdfColor.fromInt(0xFF006B5B);
  final brandSoft = PdfColor.fromInt(0xFF9CCFC4);
  final brandLight = PdfColor.fromInt(0xFFE6F2EF);
  final grey = PdfColor.fromInt(0xFF5F6B68);
  final line = PdfColor.fromInt(0xFFD5DEDB);
  final red = PdfColor.fromInt(0xFFB3261E);
  final white = PdfColors.white;
  String m(int c) => _plain(money(c));
  final maxDay = w.days.fold<int>(0, (a, d) => d.sales > a ? d.sales : a);
  final pct = w.percent;
  final generated = DateFormat("d 'de' MMMM 'de' y, HH:mm", 'es_MX')
      .format(now ?? DateTime.now());

  pw.TextStyle st(double size, {bool bold = false, PdfColor? color}) => pw.TextStyle(
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color ?? PdfColors.black);

  pw.Widget title(String t) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
        child: pw.Text(t, style: st(13, bold: true, color: brand)),
      );

  pw.Widget kpi(String label, String value, {PdfColor? color}) => pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: pw.BoxDecoration(
            color: brandLight,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: st(9, color: grey)),
              pw.SizedBox(height: 3),
              pw.Text(value, style: st(15, bold: true, color: color)),
            ],
          ),
        ),
      );

  pw.Widget cell(String t,
          {bool bold = false, bool right = false, PdfColor? color}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: pw.Align(
          alignment: right ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
          child: pw.Text(t, style: st(10, bold: bold, color: color)),
        ),
      );

  pw.TableRow header(List<String> cols) => pw.TableRow(
        decoration: pw.BoxDecoration(color: brand),
        children: [
          for (var i = 0; i < cols.length; i++)
            cell(cols[i], bold: true, right: i > 0, color: white),
        ],
      );

  pw.BoxDecoration zebra(int i) =>
      pw.BoxDecoration(color: i.isOdd ? brandLight : white);

  String avg(int sales, int tickets) =>
      tickets == 0 ? '-' : m((sales / tickets).round());

  final highlights = <String>[
    if (w.hasSales)
      'Tu mejor día fue el ${dayLong[w.bestDay.day.weekday - 1]}, con ${m(w.bestDay.sales)}.',
    if (pct != null)
      pct >= 0
          ? 'Vendiste ${pct.abs()}% más que la semana anterior.'
          : 'Vendiste ${pct.abs()}% menos que la semana anterior.',
    if (top.isNotEmpty)
      '${top.first.name} fue lo que más ganancia dejó: ${m(top.first.profit)}.',
    if (w.tickets > 0) 'Cada venta fue en promedio de ${avg(w.sales, w.tickets)}.',
    if (w.isCurrent) 'La semana sigue en curso: los números pueden cambiar.',
  ];

  final doc = pw.Document(title: 'Resumen semanal', author: business);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
      footer: (ctx) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 12),
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: line, width: 0.8))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generado con VendeMas el $generated', style: st(8, color: grey)),
            pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                style: st(8, color: grey)),
          ],
        ),
      ),
      build: (ctx) => [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: pw.BoxDecoration(
            color: brand,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(business, style: st(20, bold: true, color: white)),
                    pw.SizedBox(height: 4),
                    pw.Text('Resumen semanal', style: st(11, color: white)),
                    pw.Text(weekLabel(w), style: st(11, color: white)),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Vendido', style: st(9, color: white)),
                  pw.Text(m(w.sales), style: st(22, bold: true, color: white)),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(children: [
          kpi('Ganancia', m(w.profit)),
          pw.SizedBox(width: 8),
          kpi('Ventas registradas', '${w.tickets}'),
          pw.SizedBox(width: 8),
          kpi('Venta promedio', avg(w.sales, w.tickets)),
          pw.SizedBox(width: 8),
          kpi('Vs. semana anterior', pct == null ? '-' : signed(pct),
              color: pct == null ? null : (pct >= 0 ? brand : red)),
        ]),
        title('Ventas por día'),
        for (final d in w.days)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Row(children: [
              pw.SizedBox(width: 34, child: pw.Text(dayShort[d.day.weekday - 1], style: st(10))),
              pw.Container(
                width: maxDay == 0 ? 2.0 : math.max(2.0, 300 * d.sales / maxDay),
                height: 11,
                decoration: pw.BoxDecoration(
                  color: w.hasSales && d.sales == maxDay ? brand : brandSoft,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(m(d.sales), style: st(10)),
            ]),
          ),
        title('Detalle por día'),
        pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: line, width: 0.5),
            bottom: pw.BorderSide(color: line, width: 0.5),
          ),
          columnWidths: {
            0: pw.FlexColumnWidth(1.6),
            1: pw.FlexColumnWidth(1.3),
            2: pw.FlexColumnWidth(1.3),
            3: pw.FlexColumnWidth(1.2),
            4: pw.FlexColumnWidth(1.3),
          },
          children: [
            header(['Día', 'Ventas', 'Ganancia', 'No. de ventas', 'Promedio']),
            for (var i = 0; i < w.days.length; i++)
              pw.TableRow(
                decoration: zebra(i),
                children: [
                  cell('${cap(dayLong[w.days[i].day.weekday - 1])} ${w.days[i].day.day}'),
                  cell(m(w.days[i].sales), right: true),
                  cell(m(w.days[i].profit), right: true),
                  cell('${w.days[i].tickets}', right: true),
                  cell(avg(w.days[i].sales, w.days[i].tickets), right: true),
                ],
              ),
            pw.TableRow(
              decoration: pw.BoxDecoration(color: line),
              children: [
                cell('Total', bold: true),
                cell(m(w.sales), bold: true, right: true),
                cell(m(w.profit), bold: true, right: true),
                cell('${w.tickets}', bold: true, right: true),
                cell(avg(w.sales, w.tickets), bold: true, right: true),
              ],
            ),
          ],
        ),
        if (top.isNotEmpty) ...[
          title('Lo que más ganancia dejó'),
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: line, width: 0.5),
              bottom: pw.BorderSide(color: line, width: 0.5),
            ),
            columnWidths: {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(1.3),
              3: pw.FlexColumnWidth(1.3),
            },
            children: [
              header(['Producto', 'Piezas', 'Ventas', 'Ganancia']),
              for (var i = 0; i < top.length && i < 5; i++)
                pw.TableRow(
                  decoration: zebra(i),
                  children: [
                    cell('${i + 1}. ${top[i].name}'),
                    cell('${top[i].units}', right: true),
                    cell(m(top[i].revenue), right: true),
                    cell(m(top[i].profit), right: true),
                  ],
                ),
            ],
          ),
        ],
        if (highlights.isNotEmpty) ...[
          title('Lo más importante'),
          for (final h in highlights)
            pw.Bullet(text: h, style: st(10), bulletColor: brand),
        ],
      ],
    ),
  );
  return doc.save();
}
