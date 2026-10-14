# Express Restaurante — aplicación independiente de comercios

> **Estado al 2026-10-14: definición técnica/documental; aplicación web y APK funcionales TODAVÍA NO implementadas.** Este repositorio se inicia para desarrollar el frontend propio sin romper Express Principal. No anunciarlo como publicado ni crear pedidos reales con mockups.

## Arquitectura oficial de cuatro aplicaciones

- **Express Principal** (`jorge2610g/Expressdelivery`): cliente Taxi, cliente Envíos, cliente Delivery/restaurantes, conductor Taxi y conductor Envíos. Los **cinco recorridos permanecen allí**.
- **Express Restaurante** (este repo): solo operación del comercio, pedidos, menú/catálogo, productos, extras, inventario/horarios, promociones, liquidaciones y ajustes.
- **Express Repartidor** (`jorge2610g/Express_Repartidor`): solamente ofertas de **pedidos comerciales**, NO Taxi ni envíos entre personas.
- **Express Admin** (`jorge2610g/Adminexpress`): panel global separado; dueños de comercios NO obtienen sus privilegios.

Backend existente compartido: Supabase `zgpijrznvaskgcmauwxx`. Se debe reutilizar autenticación, RPC y RLS con protección **por negocio/usuario, zona y canal Preview/Producción**. No duplicar tablas, RPC ni secretos del backend.

## Mockup interactivo aprobado: qué implementar, no qué existe

La referencia de Express usa azul de marca, tarjetas claras, modo oscuro, diseño responsivo y navegación rápida. El mockup elaborado para revisar el rediseño era **simulado**; no sustituyó ningún pedido ni pago real.

| Pantalla o ruta objetivo | Requisitos funcionales antes de publicar |
| --- | --- |
| Acceso | Login, sesión y selección de comercio propio; nunca entrar al panel Admin por ser comerciante. |
| Inicio | Pedidos nuevos/activos, indicadores, ingresos reales visibles por moneda/ciudad; no inventar métricas. |
| Pedidos | Nuevo → aceptar/rechazar conforme reglas → preparar → listo para recoger → entregado/cancelado; acciones sincronizadas con el cliente y repartidor. |
| Detalle del pedido | Productos, modificadores, notas, pago, dirección autorizada, chat/notificación y estados con validación backend. |
| Catálogo | Categorías, menú, producto, precio, variantes/extras, foto, disponibilidad, horario, cambios guardados y visibles para el cliente. |
| Inventario y operación | Stock/agotados solo si el backend lo soporta; horarios y aperturas; sin prometer stock sin contrato. |
| Marketing | Promociones y descuentos existentes, sin insertar cobros ficticios; coordinación con cupones y Plus de Express Principal. |
| Liquidaciones | Historial y comprobantes autorizados, desglose de pedidos/comisiones y moneda real CLP/BOB. |
| Perfil | Datos del negocio, contactos, ubicación, roles, notificaciones y cierre de sesión. |
| Dispositivos | Web completa adaptable a escritorio/móvil y app Android del comercio para pedidos/notificaciones; compartir código y contratos cuando sea seguro. |

La interfaz **NO necesita incluir Taxi, conductor de envíos ni administración global**.

## Código base ya existente; REUTILIZAR sin duplicar al comprador

**No copiar la app Express Principal entera.** Extraer únicamente módulos comerciales, servicio/backend reutilizable y assets autorizados tras auditar dependencias:

- `Expressdelivery/lib/restaurant_portal_web.dart`: punto de entrada Web comercial preexistente en `/restaurantes/`, login y vista de negocios.
- `Expressdelivery/lib/marketplace_merchant_page.dart`: órdenes del comercio.
- `Expressdelivery/lib/marketplace_merchant_catalogue.dart`: catálogo.
- `Expressdelivery/lib/marketplace_merchant_settlements.dart`: liquidaciones.
- `Expressdelivery/lib/marketplace_chat_attachments.dart`: adjuntos privados; revisar reglas Storage.
- `Expressdelivery/lib/services/express_service.dart`: capa compartida grande; **separar solo contratos merchant** y nunca exportar acceso de conductor o usuario global por accidente.

El carrito, `ExpressDeliveryV2Page`, checkout, seguimiento y perfil **del comprador** siguen en Express Principal. La Administración global sigue en Adminexpress. **No retirar todavía el portal preexistente del Principal**: conservarlo para compatibilidad hasta que la nueva app pase pruebas E2E y haya un reemplazo publicado.

## Secuencia de implementación sin romper Producción

1. Clonar/configurar Flutter con `pubspec.yaml`, `lib/main.dart`, Web/Android propios, package y firma **nuevos**, sin usar `com.express.usuario1` (reservado a Principal).
2. Preparar **vista previa interactiva** fiel al mockup; revisar todas las pantallas y navegación antes de conectar operaciones reales.
3. Reutilizar autenticación Supabase del proyecto oficial con rol de negocio y aislamiento por canal/cuenta, sin secretos en código.
4. Conectar catálogo/pedidos/horarios y estados autorizados, solo usando datos Preview; verificar permisos de propietario y staff.
5. Conectar eventos/push por app de comercio (no tokens del conductor), reconexión y sincronización con cliente Delivery y repartidor.
6. Probar Preview por ciudad/moneda, dos cuentas, pedido aceptado, preparado, recogido, completado, liquidado; permisos cruzados, logout, red intermitente.
7. Entregar APK/web propios y aprobar su lanzamiento; solo entonces considerar retirar el portal legado del repo Principal, con rollback y sin borrar base/historial.

## No hacer

- No duplicar base de datos ni crear otro Supabase sin requerimiento nuevo.
- No fusionar código de Cliente Delivery aquí ni retirar sus pantallas de Express Principal.
- No permitir que un comerciante apruebe conductores o lea pedidos de otras tiendas.
- No mostrar demo como restaurante real afiliado ni reutilizar logos/menús sin derecho o autorización.
- No mezclar datos demo Producción/Preview; no activar transacciones o pagos reales por mostrar un mockup.
- No prometer entrega comercial hasta que Express Repartidor tenga despachos/push reales probados.
- Registrar cambios/retiradas/reemplazos y QA con cada commit.

**Continuidad maestra:** `Expressdelivery/docs/EXPRESS_CODE_AUDIT_AND_FOUR_APP_PLAN_20261014.md` (en rama documental hasta fusión).
