# Express Restaurante

Aplicación Android independiente para que los restaurantes gestionen pedidos de Express. Comparte el backend Supabase y las pantallas de comercio del portal existente en `https://expressviajes.online/restaurantes/`.

## Funciones

- Registro con correo y contraseña o Google.
- Solicitud de acceso con datos del restaurante y revisión de Express.
- Detección opcional del país y la ciudad mediante la ubicación del dispositivo; ambos también se pueden elegir manualmente.
- Búsqueda de dirección y ajuste del punto exacto en el mapa.
- Selección entre los restaurantes vinculados a una cuenta aprobada.
- Lista y detalle de pedidos, acciones de operación y mensajes con el cliente.
- Catálogo, disponibilidad de productos y estado de apertura.
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

La solicitud se completa después de crear e iniciar sesión en la cuenta. La ciudad determina qué requisitos documentales se muestran. La ubicación solo se usa si el usuario concede permiso; de lo contrario puede elegir país y ciudad, buscar la dirección o ajustar el marcador en el mapa. El análisis, las pruebas y la compilación de Android se ejecutan en GitHub Actions para cada cambio. No se ha probado en un dispositivo con una cuenta QA de comercio. Las notificaciones push no están configuradas. No se publicó en Play Store.

Los conductores de restaurantes usan la app Express existente y sus pantallas actuales, con permiso `market`; no necesitan una aplicación de repartidor separada.
