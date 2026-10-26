# AGENTS.md — Express Restaurante

## DIRECTIVA PRIORITARIA DEL PROPIETARIO (2026-10-26): MISMO BACKEND, CONTEXTO POR CUENTA
- Esta aplicación sigue siendo el producto Android del comercio; no es la app del repartidor ni reemplaza los flujos de Express.
- Restaurante, Express y Admin consumen la misma configuración canónica de ciudades, zonas, cobertura y servicios. No crear catálogos o zonas duplicados para QA.
- El contexto Preview/Producción se asigna por la cuenta autenticada en el backend. Pedidos, pagos, liquidaciones y trazabilidad mantienen el contexto de esa cuenta y no se cruzan con cuentas del otro entorno.
- Mantener la seguridad en RLS/RPC/Edge Functions además de la interfaz. No introducir una selección local de entorno que pueda falsificar la identidad asignada.
- No activar servicios comerciales por zona ni cambiar pagos reales debido a una versión o build.
- Antes de alterar el modelo, leer `docs/UNIFIED_ACCOUNT_ENVIRONMENT_HANDOFF_20261026.md` y el mismo archivo en `jorge2610g/Expressdelivery` y `jorge2610g/Adminexpress`.
- No editar migraciones aplicadas ni eliminar historial. Usar migraciones nuevas y conservar compatibilidad hasta verificar clientes y backend.
