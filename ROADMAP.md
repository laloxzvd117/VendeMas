# ROADMAP de VendeMas

Cinco fases; cada una deja algo que se puede probar. Los IDs (RF, RNF, F) son los del
documento de requerimientos.

Leyenda: ✅ hecho · 🟨 parcial · 🔄 en curso · ⬜ pendiente

## Fase 1. Análisis y diseño 🔄
- ✅ Requerimientos y formularios definidos.
- ✅ Prototipo interactivo en HTML.
- ⬜ Validar el prototipo con 3 a 5 comerciantes.

## Fase 2. Base de la app ✅
Formularios F-01 a F-07 · RF-01 a RF-07 · RNF-02 a RNF-05
- ✅ Proyecto Flutter, tema Material 3 claro/oscuro, español (MX).
- ✅ Base local drift sin conexión, aislada por cuenta.
- ✅ Bienvenida, inicio, nueva venta, cobro con cambio, venta registrada.
- ✅ Catálogo con margen y alta de productos.
- ✅ Tarjetas de la pantalla de venta ajustadas al contenido (nombres largos ya no se cortan).
- ✅ Pruebas de cálculos, base de datos y flujo de pantallas.
- ✅ Probado en celular (Xiaomi 23122PCD1G) y en Linux Mint.

## Fase 3. Existencias y reportes ✅
Formularios F-08 a F-19 · RF-09 a RF-20
- ✅ Pantalla de existencias: qué se acaba y cuánto alcanza (F-08).
- ✅ Hoja para registrar entradas, conteos y activar/desactivar control (F-09, RF-10).
- ✅ Menú de reportes con el hallazgo de cada uno (F-10).
- ✅ Más vendidos y más rentables, por piezas y por ganancia (F-11).
- ✅ Clasificación ABC por ganancia (F-12).
- ✅ Margen y rotación (F-13).
- ✅ Productos muertos (F-14).
- ✅ Horas y días fuertes (F-15).
- ✅ Se venden juntos, con idea de combo (F-16).
- ✅ Tendencias contra la semana anterior (F-17).
- ✅ Resumen semanal con historial de 8 semanas (F-18).
- ✅ Exportar a PDF, CSV e imagen con menú de compartir (F-19, RF-20).
- ✅ Recomendaciones de "Para hoy" en el inicio.
- ✅ Cálculos compartidos (`lib/domain/reports.dart`): celular y computadora muestran lo mismo.
- ✅ Exportación rediseñada: PDF con encabezado, indicadores, gráfica, tabla con promedio, top productos y resumen. CSV con secciones. Imagen como tarjeta con vista previa. En computadora se guarda en Descargas.
- ✅ Semilla de abarrotes (Ajustes → Datos de ejemplo) para ver todos los reportes.
- ✅ Probado en celular y computadora con la semilla de 9 semanas.

## Fase 4. Cuentas, sincronización y computadora 🔄
Formularios F-20 a F-24 · RF-08, RF-21 a RF-24 · RNF-01, RNF-06 a RNF-08
- ✅ Acceso con número de teléfono y "Recordar usuario" (F-24). El número se guarda como hash PBKDF2-HMAC-SHA256 con sal fija y 20,000 repeticiones; nunca en texto plano.
- ✅ Datos aislados por cuenta: cada número abre su propia base local (RF-24, versión local).
- ✅ Ajustes del celular (F-20): editar nombre del negocio (F-21), ver cuenta, panel de conexión con la computadora, cargar datos de ejemplo y cerrar sesión (F-22).
- ✅ Vista de escritorio de solo consulta, con los mismos cálculos que el celular (F-23), cuenta, cerrar sesión y botón de exportar.
- ✅ Animación de la barra lateral de la computadora corregida (sin lag).
- ✅ Sincronización temporal por red local (RNF-06, versión LAN):
  - El celular comparte sus datos en un servidor HTTP mientras la app está abierta.
  - La computadora encuentra al celular por difusión UDP y copia cada 5 s.
  - Opción de escribir la dirección IP a mano si el router bloquea la difusión.
  - Importar dos veces no duplica: cada registro lleva su UUID.
  - Otra cuenta no puede leer los datos del celular.
- 🟨 RF-08 (sin conexión y sincronizar): la base funciona sin conexión; falta el indicador de conexión y la cola de pendientes.
- ⬜ Servidor en la nube con datos aislados por negocio (Row Level Security) (RF-24).
- ⬜ Código por SMS (completar F-24).
- ⬜ Respaldo en la nube y recuperación en otro dispositivo (RNF-08).
- ⬜ Exportar todos los datos del negocio (RF-21).
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
- La sincronización por red local es temporal: no cifra los datos en tránsito y solo
  funciona dentro de la misma Wi-Fi. La versión en la nube la reemplaza.
- Un número de 10 dígitos tiene pocas combinaciones posibles: el hash no protege
  contra quien pueda probar todos los números en el servidor. Lo resuelve el código por SMS.
- Algunos routers bloquean la comunicación entre equipos de la misma red
  ("aislamiento de clientes"); la opción de escribir la IP a mano lo mitiga.
- Pruebas de pantalla con drift necesitan `runAsync`; mantener ese patrón.
