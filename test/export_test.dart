import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendemas/domain/reports.dart';
import 'package:vendemas/features/reports/export_sheet.dart';

import 'reports_test.dart' as scenario;

void main() {
  setUpAll(() => initializeDateFormatting('es_MX'));

  final d = scenario.scenario();
  final w = lastWeeks(d).last;
  final top = weekProducts(d, w.start);

  test('productos de la semana, por ganancia', () {
    expect(top.map((p) => p.name), ['Concha', 'Café']);
    expect(top.first.units, 6);
  });

  test('el CSV del resumen lleva datos, una fila por día, total y productos (RF-20)', () {
    final csv = weekCsv(w, business: 'Abarrotes "Lupe", centro', top: top);

    // El BOM hace que Excel respete los acentos.
    expect(csv.startsWith('﻿'), isTrue);

    final lines = csv.substring(1).trim().split('\n');
    expect(lines[0], 'Resumen semanal');
    expect(lines[1], 'Negocio,"Abarrotes ""Lupe"", centro"');
    expect(lines[2], 'Semana,Semana del 2 al 8 de noviembre');
    expect(lines[3], '');
    expect(lines[4], 'Fecha,Día,Ventas,Ganancia,Número de ventas,Venta promedio');
    expect(lines[5], '2026-11-02,Lun,0.00,0.00,0,0.00');
    expect(lines[6], '2026-11-03,Mar,45.00,25.50,1,45.00');
    expect(lines[7], '2026-11-04,Mié,95.00,61.50,2,47.50');
    expect(lines[12], 'Total,,140.00,87.00,3,46.67');
    expect(lines[14], 'Producto,Piezas,Ventas,Ganancia');
    expect(lines[15], 'Concha,6,90.00,51.00');
  });

  test('el PDF del resumen se genera', () async {
    final bytes = await weekPdf('La Espiga', w, top, now: DateTime(2026, 11, 4, 12));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(1500));
  });
}
