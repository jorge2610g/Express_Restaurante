# Inventario verificable del mockup interactivo Express Delivery (2026-10-14)

Este archivo documenta el prototipo **`express_delivery_mockup.html`** creado para revisar navegación/rediseño: diseño responsive móvil de marca azul Express y datos ficticios. **No es código Flutter ni una app conectada**. El prototipo ofrece 34 pantallas por rol (16 cliente, 6 comercio, 5 repartidor, 7 admin). Su rol comercial es referencia para **Express Restaurante**, mientras el resto se implementa en sus repos respectivos.

## Pantallas del prototipo por rol

| Rol | Pantalla / identificador del mockup | Repositorio destino |
| --- | --- | --- |
| Cliente (16) | `inicio`, `restaurantes`, `local`, `producto`, `carrito`, `pago`, `confirmado`, `seguimiento`, `chat`, `pedidos`, `promociones`, `cupones`, `plus`, `perfil`, `direcciones`, `avisos` | `Expressdelivery` (Principal, **no mover**) |
| Comercio (6) | `comercio` (Resumen), `pedidos_comercio`, `catalogo`, `promos_comercio`, `caja` (Liquidaciones), `perfil_comercio` | `Express_Restaurante` |
| Repartidor (5) | `ofertas`, `servicio`, `ganancias`, `historial`, `perfil_repartidor` | `Express_Repartidor`, con mapa real y ofertas comerciales |
| Admin (7) | `admin`, `zonas`, `restaurantes_admin`, `cupones_admin`, `planes_admin`, `ordenes_admin`, `repartidores_admin` | `Adminexpress` (**ya independiente**) |

## Flujos interactivos que eran SIMULACIÓN

- Cliente: elegir restaurante, producto/cantidad, agregar carrito, pagar, obtener confirmación, avanzar seguimiento, chat de ejemplo; ingresar cupones, Plus y perfil.
- Comercio: ver pedidos de prueba, cambiar etapa visualmente, menú/productos, promociones, liquidaciones simuladas, estado abierto/cerrado.
- Repartidor: aceptar oferta ficticia de pedido `#DEMO-2401`, avanzar etapas de recogida/entrega, ver ganancias e historial ficticios.
- Admin: ver ejemplos de comercios, zonas, pedidos, cupones y planes, sin crear configuraciones reales.

Los importes, reputaciones, ganancias, cupones, clientes, zonas y locales del prototipo son **datos visuales de ejemplo**. No se transfieren a Supabase ni deben reemplazar precios reales, datos de cliente, autorizaciones, planes o dinero.

## Límites de la referencia aprobada

1. Se aprobó utilizar este diseño como base de rediseño; **no se aprobó un cambio automático de backend ni una publicación inmediata**.
2. El usuario pidió que el **conductor Taxi y Envíos siga dentro de Principal**; las vistas de Repartidor del prototipo son **solo para entregas de restaurantes/tiendas**.
3. El portal del comercio debe existir en web y Android, separado del perfil cliente.
4. «Mercados» debe mostrarse como **«Restaurantes»** en la navegación cliente, y «Market» visible como **Delivery** (mantener nombres técnicos legacy mientras haya dependencias).
5. El mockup no tiene mapa de calle/ruta real ni envío de push real; eso requiere desarrollo funcional.
6. El prototipo completo de los cuatro roles **no está incorporado en este repo como aplicación**. Conservar esta lista como inventario de navegación y rehacer los widgets Flutter con controles reales.

## Criterios de aceptación del rediseño comercial

La app de Restaurante debe poder navegar sin recarga total entre **Inicio/Resumen, Pedidos, Menú, Promociones, Liquidaciones y Mi restaurante**, ser responsiva, usar modo oscuro/claro, estado de pedido desde servidor, catálogo editable autorizado, rutas seguras y pruebas por canal. No exponer Admin, no tocar Taxi y no modificar al cliente Delivery.

Referencia de implementación: `README.md` de este repo y auditoría maestra en `Expressdelivery/docs/EXPRESS_CODE_AUDIT_AND_FOUR_APP_PLAN_20261014.md`.
