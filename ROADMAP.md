# ROADMAP de VendeMas

Cinco fases; cada una deja algo que se puede probar. Los IDs (RF, RNF, F) son los del
documento de requerimientos.

Leyenda: ✅ hecho · 🔄 en curso · ⬜ pendiente

## Fase 1. Análisis y diseño 🔄
- ✅ Requerimientos y formularios definidos.
- ✅ Prototipo interactivo en HTML.
- ⬜ Validar el prototipo con 3 a 5 comerciantes.

## Fase 2. Base de la app ✅
Formularios F-01 a F-07 · RF-01 a RF-07 · RNF-02 a RNF-05
- ✅ Proyecto Flutter, tema Material 3 claro/oscuro, español (MX).
- ✅ Base local drift sin conexión.
- ✅ Bienvenida, inicio, nueva venta, cobro con cambio, venta registrada.
- ✅ Catálogo con margen y alta de productos.
- ✅ Pruebas de cálculos, base de datos y flujo de pantallas.
- ⬜ Probar en un dispositivo real (`flutter run`) y ajustar el diseño.

## Fase 3. Existencias y reportes ⬜
Formularios F-08 a F-19 · RF-09 a RF-20
- ⬜ Pantalla de existencias: qué se acaba y cuánto alcanza (F-08).
- ⬜ Hoja para registrar entradas, conteos y activar/desactivar control (F-09, RF-10).
- ⬜ Menú de reportes (F-10).
- ⬜ Más vendidos y más rentables (F-11).
- ⬜ Clasificación ABC (F-12).
- ⬜ Margen y rotación (F-13).
- ⬜ Productos muertos (F-14).
- ⬜ Horas y días fuertes, con fl_chart (F-15).
- ⬜ Se venden juntos (F-16).
- ⬜ Tendencias (F-17).
- ⬜ Resumen semanal con historial de 8 semanas (F-18).
- ⬜ Exportar a PDF, CSV e imagen con menú de compartir (F-19).
- ⬜ Recomendaciones de "Para hoy" en el inicio.

## Fase 4. Cuentas, sincronización y computadora ⬜
Formularios F-20 a F-24 · RF-08, RF-21 a RF-24 · RNF-01, RNF-06 a RNF-08
- ⬜ Acceso con número de teléfono (Supabase, código por SMS) (F-24).
- ⬜ Servidor con datos aislados por negocio (Row Level Security) (RF-24).
- ⬜ Cola de pendientes y sincronización sin duplicados (RNF-06).
- ⬜ Estado de conexión con connectivity_plus, confirmado con la sincronización real.
- ⬜ Ajustes: nombre del negocio, cuenta, exportar todos los datos, cerrar sesión (F-20 a F-22).
- ⬜ Respaldo en la nube y recuperación en otro dispositivo (RNF-08).
- ⬜ Vista de escritorio de solo consulta, con los mismos cálculos que el celular (F-23).
- ⬜ Agregar iOS si hay una Mac disponible.

## Fase 5. Pruebas y cierre ⬜
- ⬜ Dos semanas de pruebas con comerciantes reales.
- ⬜ Ajustes según lo observado.
- ⬜ Documentación final.
- **Criterio para avanzar:** que el comerciante registre al menos 8 de cada 10 de sus
  ventas. Si no, se mejora la rapidez de captura antes de agregar funciones.

## Trabajo futuro (fuera de alcance)
Recetas y costo de materia prima, roles para empleados, varios negocios por dueño,
módulos por giro (venta por peso, caducidad, variantes), corte de caja y facturación.

## Riesgos abiertos
- Costo y configuración del proveedor de SMS para el acceso por teléfono.
- La sincronización con Supabase se escribe a mano: no hay sincronización offline lista.
- Pruebas de pantalla con drift necesitan `runAsync`; mantener ese patrón.
