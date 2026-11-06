import 'package:flutter_test/flutter_test.dart';
import 'package:vendemas/domain/reports.dart';
import 'package:vendemas/features/reports/export_sheet.dart';

import 'reports_test.dart' as scenario;

void main() {
  test('el CSV del resumen semanal lleva una fila por día y el total (RF-20)', () {
    final w = lastWeeks(scenario.scenario()).last;
    final csv = weekCsv(w);

    // El BOM hace que Excel respete los acentos.
    expect(csv.startsWith('﻿'), isTrue);

    final lines = csv.substring(1).trim().split('\n');
    expect(lines.first, 'Fecha,Día,Ventas,Ganancia,Número de ventas');
    expect(lines.length, 9); // encabezado + 7 días + total
    expect(lines[1], '2026-11-02,Lun,0.00,0.00,0');
    expect(lines[2], '2026-11-03,Mar,45.00,25.50,1');
    expect(lines[3], '2026-11-04,Mié,95.00,61.50,2');
    expect(lines.last, 'Total,,140.00,87.00,3');
  });
}