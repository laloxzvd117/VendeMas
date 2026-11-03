class ReportData {
  static const weekLabels = ['07/09', '14/09', '21/09', '28/09', '05/10', '12/10', '19/10', '26/10'];
  static const weekTotals = [6200, 6600, 6700, 6500, 7000, 7100, 7400, 7501];
  static const weekRanges = [
    '7 al 13 de septiembre',
    '14 al 20 de septiembre',
    '21 al 27 de septiembre',
    '28 de septiembre al 4 de octubre',
    '5 al 11 de octubre',
    '12 al 18 de octubre',
    '19 al 25 de octubre',
    '26 de octubre al 1 de noviembre',
  ];
  static const dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const dayBase = [850, 880, 960, 1010, 1190, 1450, 1161];
  static const marginPct = 58.9;
  static const ticketsLatest = 167;

  static const rank = [
    ('Bolillo', 980, 2940.0),
    ('Concha', 410, 3485.0),
    ('Café americano', 300, 5400.0),
    ('Cuernito', 180, 1800.0),
    ('Dona glaseada', 140, 1260.0),
    ('Empanada', 90, 900.0),
    ('Tamal', 70, 630.0),
    ('Pan de muerto', 60, 1260.0),
    ('Rebanada de pastel', 25, 375.0),
    ('Pan integral', 8, 192.0),
    ('Galleta de avena', 4, 28.0),
  ];

  static const abc = [
    ('Café americano', 'A', 33.1, 33.1),
    ('Concha', 'A', 21.4, 54.5),
    ('Bolillo', 'A', 18.0, 72.5),
    ('Cuernito', 'B', 11.0, 83.5),
    ('Pan de muerto', 'B', 7.7, 91.2),
    ('Dona glaseada', 'B', 7.7, 98.9),
    ('Empanada', 'C', 5.5, 97.7),
    ('Tamal', 'C', 3.9, 98.6),
    ('Rebanada de pastel', 'C', 2.3, 99.2),
    ('Pan integral', 'C', 1.2, 99.9),
    ('Galleta de avena', 'C', 0.2, 100.0),
  ];

  static const matrix = [
    ('Estrellas', 'Alta rotación + alto margen', ['Café americano', 'Concha', 'Cuernito']),
    ('Joyas ocultas', 'Baja rotación + alto margen', ['Pan de muerto', 'Rebanada de pastel', 'Pan integral']),
    ('Alto volumen', 'Alta rotación + bajo margen', ['Bolillo', 'Dona glaseada']),
    ('Revisar', 'Baja rotación + bajo margen', ['Empanada', 'Tamal', 'Galleta de avena']),
  ];

  static const dead = [
    ('Pan integral', 21, 12, 192.0),
    ('Galleta de avena', 34, 30, 150.0),
  ];

  static const hours = [
    (7, 180), (8, 620), (9, 540), (10, 310), (11, 260), (12, 330), (13, 410),
    (14, 280), (15, 240), (16, 420), (17, 610), (18, 560), (19, 320), (20, 150),
  ];

  static const pairs = [
    ('Café americano', 'Concha', 58),
    ('Café americano', 'Pan de muerto', 34),
    ('Cuernito', 'Café americano', 27),
    ('Bolillo', 'Empanada', 21),
  ];

  static const trends = [
    ('Pan de muerto', 24, 13, 85),
    ('Café americano', 74, 66, 12),
    ('Dona glaseada', 28, 41, -32),
    ('Bolillo', 215, 236, -9),
  ];
}
