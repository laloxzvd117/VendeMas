# VendeMas

Punto de venta multiplataforma para pequeños comerciantes y productores informales.
Registra ventas rápido, aun sin internet, y convierte esos datos en recomendaciones
claras: qué producto impulsar, cuál dejar de comprar y qué se está acabando.

El celular es la herramienta de trabajo diario; la computadora sirve solo para
consultar reportes. El plan de trabajo está en [ROADMAP.md](ROADMAP.md).

## Estado

Fase 2 (base de la app) terminada: funciona sin conexión con base de datos local.
Ver el [ROADMAP](ROADMAP.md) para lo que sigue.

| Ya funciona | Pendiente |
|---|---|
| Bienvenida, inicio, nueva venta, cobro con cambio, venta registrada | Pantalla de existencias y reportes |
| Catálogo con margen y alta de productos | Resumen semanal y exportación |
| Existencias opcionales que bajan con cada venta | Acceso con teléfono, nube y sincronización |
| Tema Material 3 claro/oscuro y textos en español (MX) | Vista de escritorio (solo consulta) |

## Tecnologías

Flutter (Material 3) · Riverpod · go_router · drift (SQLite) · intl · uuid.
Previstas para fases siguientes: supabase_flutter, connectivity_plus, fl_chart,
pdf, csv, share_plus, file_selector.

## Estructura

```
lib/
  main.dart            arranque, tema y localización
  router.dart, shell.dart   rutas y barra de navegación (4 pestañas)
  providers.dart       providers de Riverpod (base de datos, carrito, ventas)
  core/                tema y formato de dinero/fechas
  domain/              cálculos puros (total, cambio, margen, montos sugeridos)
  data/                base de datos drift (tablas y consultas)
  features/            pantallas por área: onboarding, home, sell, products, reports
test/                  cálculos, base de datos en memoria y flujo de pantallas
```

## Decisiones de diseño

- **Dinero en centavos enteros** en toda la app, para evitar errores de redondeo.
- **Existencias = suma de movimientos.** No se editan directamente; cada venta,
  entrada o conteo es un registro.
- **Registros con UUID v7** y campo `syncedAt`, para que la sincronización futura
  no duplique ni sobrescriba datos.
- **No se registra la forma de pago**: ningún reporte la usa.

## Cómo ejecutarlo

Requisitos: Flutter estable (3.47 o superior) con soporte de Linux, Windows o Android.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera database.g.dart
flutter run -d linux        # o windows / un dispositivo Android
```

Los archivos `*.g.dart` no se suben al repositorio: hay que generarlos después de
clonar y cada vez que cambie `lib/data/database.dart`.

## Pruebas y calidad

```bash
flutter analyze
flutter test
```

Las pruebas de pantalla que tocan la base de datos dejan pasar tiempo real
(`runAsync`), porque drift usa E/S real y el reloj falso de `testWidgets` no la espera.

## Plataformas

Hoy el proyecto tiene Android, Linux y Windows.
