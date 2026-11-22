# Alba

Reloj de mesa de noche y cocina para un Huawei Mate 20 Lite reutilizado: en horizontal, siempre enchufado, sin internet y como launcher. Reúne reloj, alarma, aviso de batería, sonidos para dormir, temporizadores de cocina y marco de fotos.

Monorepo Melos 8 con pub workspaces. Los paquetes comunes (`core_di`, `core_events`, `core_contracts`, `core_utils`, `core_ui`, `storage_isar`) vienen de [flutter_shared](https://github.com/cristian2024/flutter_shared) por etiqueta git.

| Carpeta | Contenido |
| :--- | :--- |
| `apps/alba` | La app: compone plugins y adaptadores |
| `packages/` | Contratos, adaptadores, plugins y `design_system` |
| `tool/` | Análisis, verificador de arquitectura y pruebas de lo que cambia |
| `design/` | Referencias de diseño exportadas de Penpot y auditoría |

## Comandos

```bash
dart pub global activate melos 8.9.0
melos bs
melos run verify
```

Más detalle en `CLAUDE.md` y en `PLAN.md`.
