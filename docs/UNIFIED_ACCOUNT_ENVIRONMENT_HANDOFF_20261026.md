# Handoff: Express Restaurante en el flujo común

Fecha 2026-10-26.

Express Restaurante es la aplicación del comercio y su portal sigue siendo independiente como interfaz de producto. Comparte backend y configuración operativa canónica con Express y Admin.

- Las cuentas de QA y las de Producción usan el mismo flujo y los mismos servicios disponibles; el backend determina el contexto según la identidad autenticada.
- Cada pedido y registro financiero conserva el contexto de su cuenta. No asignar pedidos Preview a comercios/conductores de Producción, ni mezclar pagos, liquidaciones o historial.
- Ciudades, zonas, cobertura y flags comerciales se configuran una sola vez. No crear una zona Preview paralela para poder probar desde otra ciudad.
- El filtro operativo de Admin no cambia el contexto de un comercio ni cambia la configuración global.
- Esta app no implementa el rol repartidor. El conductor repartidor de pedidos comerciales usa la app principal Express; no duplicar sus pantallas aquí.
- No alterar llaves, claves del comercio, QR ni pagos al cambiar de entorno. Cualquier pasarela debe seguir su autorización y configuración existente.

Antes de cualquier cambio que afecte el contexto, revisar `AGENTS.md` y coordinar la migración con Admin y Express. No tocar los worktrees locales con cambios pendientes del propietario; no reescribir migraciones ya aplicadas.
