# VendeMas 🏪

App de punto de venta (POS) multiplataforma para pequeños comerciantes.  
Construida con Flutter + Node.js + PostgreSQL, arquitectura Clean Architecture.

---

## Plataformas

| Plataforma | Vista | 
|---|---|
| Android / iOS | Vender, productos, inicio, reportes móvil | 
| Linux / Windows / macOS | Solo reportes (consulta, solo lectura) |
| Web (Chrome) | Vista móvil para desarrollo | 

---

## Stack

- **Frontend:** Flutter 3.x · Material 3 · Provider · GoRouter · Drift (SQLite)
- **Backend:** Node.js · Express · PostgreSQL 15
- **Auth:** OTP / SMS *(planeado)*
- **Offline-first:** SQLite local con sincronización al servidor

---

## Estructura del proyecto

**Backend** — API REST Node.js

```
backend/
├── .env.example
├── package.json
└── src/
    ├── app.js
    ├── server.js
    ├── config/
    │   ├── database.js
    │   └── server.js
    ├── controllers/
    ├── database/
    │   └── migrations/
    │       └── 001_initial_schema.sql
    ├── middlewares/
    ├── models/
    ├── routes/
    ├── services/
    └── utils/
```

**Frontend** — App Flutter

```
frontend/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── data/
│   │   │   └── report_data.dart
│   │   ├── database/
│   │   │   └── app_database.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── formatters.dart
│   │       └── uuid_generator.dart
│   ├── domain/
│   │   └── entities/
│   │       ├── business.dart
│   │       ├── product.dart
│   │       ├── sale.dart
│   │       ├── stock_movement.dart
│   │       └── weekly_summary.dart
│   └── presentation/
│       ├── desktop/
│       │   ├── desktop_shell.dart
│       │   ├── views/
│       │   │   ├── desk_weekly_view.dart
│       │   │   ├── desk_rank_view.dart
│       │   │   ├── desk_abc_view.dart
│       │   │   ├── desk_matrix_view.dart
│       │   │   ├── desk_dead_view.dart
│       │   │   ├── desk_hours_view.dart
│       │   │   ├── desk_pairs_view.dart
│       │   │   └── desk_trend_view.dart
│       │   └── widgets/
│       │       └── desk_widgets.dart
│       ├── providers/
│       │   ├── business_provider.dart
│       │   ├── cart_provider.dart
│       │   ├── product_provider.dart
│       │   └── sale_provider.dart
│       ├── screens/
│       │   ├── shell_screen.dart
│       │   ├── onboarding/
│       │   │   └── onboarding_screen.dart
│       │   ├── home/
│       │   │   └── home_screen.dart
│       │   ├── sell/
│       │   │   └── sell_screen.dart
│       │   ├── pay/
│       │   │   ├── pay_screen.dart
│       │   │   └── confirmation_screen.dart
│       │   ├── products/
│       │   │   ├── products_screen.dart
│       │   │   ├── add_product_screen.dart
│       │   │   └── stock_screen.dart
│       │   ├── reports/
│       │   │   ├── reports_menu_screen.dart
│       │   │   ├── weekly/weekly_screen.dart
│       │   │   ├── rank/rank_screen.dart
│       │   │   ├── abc/abc_screen.dart
│       │   │   ├── matrix/matrix_screen.dart
│       │   │   ├── dead/dead_screen.dart
│       │   │   ├── hours/hours_screen.dart
│       │   │   ├── pairs/pairs_screen.dart
│       │   │   └── trend/trend_screen.dart
│       │   └── settings/
│       │       └── settings_screen.dart
│       └── widgets/
│           ├── cart_bar.dart
│           ├── hero_card.dart
│           ├── product_tile.dart
│           └── sale_list_item.dart
└── test/
    └── widget_test.dart
```

---

## Instalación

### Frontend (Flutter)

```bash
cd frontend

# Instalar dependencias
flutter pub get

# Generar código de Drift (base de datos local)
dart run build_runner build

# Correr en Linux
flutter run -d linux

# Correr en Chrome (vista móvil)
flutter run -d chrome
```

### Backend (Node.js)

```bash
cd backend

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de PostgreSQL

# Crear la base de datos
psql -U postgres -c "CREATE DATABASE vendemas;"
psql -U postgres -d vendemas -f src/database/migrations/001_initial_schema.sql

# Iniciar servidor
npm run dev
```

---

## Variables de entorno (backend)

Copia `.env.example` a `.env` y completa:

```
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=vendemas
DB_USER=vendemas_user
DB_PASSWORD=tu_password
JWT_SECRET=cambia_esto_en_produccion
```

---

## Reportes disponibles (escritorio)

1. **Resumen semanal** — ventas de las últimas 8 semanas, selector de semana, exportar PDF/CSV
2. **Más vendidos** — ranking por unidades y por ingreso
3. **Análisis ABC** — clasificación A/B/C por contribución al ingreso
4. **Margen y rotación** — matriz estrella / joya oculta / alto volumen / revisar
5. **Productos muertos** — sin venta en 14+ días con costo inmovilizado
6. **Horas fuertes** — ventas por hora del día
7. **Se venden juntos** — pares de productos frecuentes
8. **Tendencias** — semana actual vs semana anterior

---

## Desarrollo

**Cada vez que modifiques `app_database.dart`** debes regenerar el código:

```bash
cd frontend
dart run build_runner build
```
