# Express Restaurante

Aplicación Android independiente para que los restaurantes gestionen pedidos de Express. Comparte el backend Supabase y las pantallas de comercio del portal existente en `https://expressviajes.online/restaurantes/`.

## Funciones

- Registro con correo y contraseña o Google.
- Solicitud de acceso con datos del restaurante y revisión de Express.
- Detección opcional del país y la ciudad mediante la ubicación del dispositivo; ambos también se pueden elegir manualmente.
- Búsqueda de dirección y ajuste del punto exacto en el mapa.
- Selección entre los restaurantes vinculados a una cuenta aprobada.
- Portal completo del restaurante (mismo diseño y reglas que `https://expressviajes.online/restaurantes/`): inicio con resumen, pedidos y mensajes con el cliente, productos y categorías, horarios, balance, reportes, reseñas, perfil y soporte.
- Locales que solo piden repartidor: **Solicitar repartidor** (dirección con sugerencias, ruta y delivery calculados por el sistema, cobro pedido + delivery con vuelto, o solo entregar sin cobro al cliente), **Mis solicitudes** con filtros por estado (en proceso, completadas, canceladas, sin repartidor) y un perfil simple (nombre, correo, costo del delivery y ubicación del local).
- Avisos dentro de la app (mensaje y sonido del sistema) cuando llega un pedido o cambia el estado de una solicitud de repartidor, mientras la app está abierta.
- Catálogo con fotos desde la galería, disponibilidad de productos y estado de apertura.
- Liquidaciones semanales y envío de comprobantes.

El Android application ID es `online.expressviajes.express_restaurante`, separado de `com.express.usuario1`. Las operaciones usan los RPC existentes; Supabase conserva la autorización por cuenta, comercio y entorno. No se copian secretos ni se crea otro backend.

## Compilar y revisar

```sh
flutter pub get
flutter analyze --no-pub --no-fatal-infos
flutter test --no-pub
flutter build apk --debug --target-platform android-arm64
```

La versión Release requiere un keystore propio configurado fuera del repositorio. El acceso por enlace/OAuth usa `online.expressviajes.express_restaurante://login-callback/`; ese callback debe estar permitido en Auth de Supabase antes de habilitar esos métodos en un lanzamiento.

## Estado

La solicitud se completa después de crear e iniciar sesión en la cuenta. La ciudad determina qué requisitos documentales se muestran. La ubicación solo se usa si el usuario concede permiso; de lo contrario puede elegir país y ciudad, buscar la dirección o ajustar el marcador en el mapa. El análisis, las pruebas y la compilación de Android se ejecutan en GitHub Actions para cada cambio. No se ha probado en un dispositivo con una cuenta QA de comercio. Las notificaciones push con la app cerrada no están configuradas (los avisos funcionan con la app abierta). La impresión automática de comandas y la descarga de reportes son solo de la web; en el teléfono el reporte se copia al portapapeles. No se publicó en Play Store.

Los conductores de restaurantes usan la app Express existente y sus pantallas actuales, con permiso `market`; no necesitan una aplicación de repartidor separada.
