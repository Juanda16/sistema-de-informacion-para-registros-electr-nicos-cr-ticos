# Sistema de información para registros electrónicos críticos (TPS/MIS)

**Práctica profesional — Ingeniería de Sistemas, Universidad de Antioquia**

Proyecto desarrollado en colaboración entre la **Universidad de Antioquia** y **Nova Control S.A.S.** (Medellín): diseño, implementación y validación de un sistema de información alineado con **FDA 21 CFR Part 11** e integridad de datos (**ALCOA+**), sobre la plataforma **SCADA AVEVA Edge** y **Microsoft SQL Server**, en el contexto de la envasadora de polvos **All-Fill**.

## Autores

- Laura Cecilia Tobón Ospina  
- Juan David Arismendy Pulgarín  

**Asesor UdeA:** Jaime Humberto Fonseca Espinal  
**Asesor en empresa:** Manuel Mauricio Goez Mora (Nova Control S.A.S.)

## Confidencialidad

Parte del contenido (informe, manuales y detalles de planta) está marcado como **confidencial** frente a terceros. Este repositorio debe usarse solo entre **autorizados** (UdeA, Nova Control, colaboradores explícitos). No publicar en foros abiertos ni exponer credenciales, IPs ni datos de producción.

## Objetivo (resumen)

Transformar datos operativos (alarmas, eventos, setpoints, acciones de operador) en **registros electrónicos íntegros y auditables**: captura tipo **TPS**, reportes y trazabilidad tipo **MIS**, con controles de seguridad, **firma electrónica**, **audit trail** persistido en SQL Server, restricciones de alteración/borrado, auditoría de servidor y endurecimiento del sistema operativo según el manual técnico del proyecto.

## Stack principal

| Componente | Uso |
|------------|-----|
| **AVEVA Edge** | SCADA/HMI, seguridad Part 11, e-signatures, persistencia hacia SQL |
| **Microsoft SQL Server** | Base de datos corporativa, históricos, lockdown, SQL Audit |
| **Windows** | Estación industrial; ACL NTFS sobre datos SQL; gateway AVEVA |
| **PLC / proceso** | Integración con proceso All-Fill (p. ej. Schneider, Mitsubishi, variador, servo) |

La propuesta inicial contemplaba SQLite; en la ejecución se adoptó **SQL Server** por concurrencia, permisos, auditoría y encaje con TI corporativa.

## Estructura del repositorio

```
├── README.md                 # Este archivo
├── .gitignore
├── docs/
│   └── configuracion-git-mac.md   # Cuenta GitHub / identidad separada del trabajo (Mac)
├── scripts/
│   ├── sql/                  # Scripts T-SQL (orden sugerido por prefijo)
│   └── powershell/         # Blindaje NTFS carpeta de datos SQL
├── aveva/                    # Reservado para exportes/notas del proyecto SCADA
└── [documentos de práctica: informe, manuales, propuesta en PDF/DOCX]
```

Los documentos académicos y de empresa en la raíz son la **fuente normativa y de contexto**; la automatización repetible del despliegue de BD está en **`scripts/`**.

## Scripts SQL (orden recomendado)

Ejecutar en **SQL Server Management Studio** (o herramienta equivalente), tras revisar nombres de base de datos, rutas y **sustituir placeholders de contraseña**. No ejecutar en producción sin validación interna (IQ/OQ).

| Archivo | Descripción breve |
|---------|-------------------|
| `01_create_database_template.sql` | Referencia / plantilla de creación de BD |
| `02_create_logins_and_scada_user.sql` | Logins `Admin_Dba` y `User_Aveva`, roles y permisos mínimos para AVEVA |
| `03_lockdown_disable_windows_and_sa.sql` | Deshabilitar `sa` y ajuste de logins Windows según procedimiento |
| `04_deny_update_delete_historical_tables.sql` | `DENY DELETE/UPDATE` sobre tablas de histórico (ajustar nombres reales) |
| `05_add_row_checksum_columns.sql` | Columnas `RowChecksum` (BINARY_CHECKSUM persistido) en históricos |
| `05_verify_row_checksums.sql` | Verificación: filas donde checksum guardado ≠ recalculado |
| `06_sql_server_audit.sql` | Auditoría a archivo + especificaciones servidor/BD |
| `99_emergency_sql_recovery_notes.sql` | Notas de rescate ante lockout (sqlcmd); no es un script único de ejecución |

**PowerShell:** `scripts/powershell/Lockdown-SqlDataDirectory.ps1` — restringe ACL de la carpeta de datos de SQL; ejecutar como administrador y con ruta validada.

**AVEVA Edge:** gran parte de la configuración (tags, pantallas, Database Gateway, `StADOSvr.exe`, cadenas de conexión) vive en el proyecto del software; esta carpeta `aveva/` puede alojar exportes o checklists cuando los organicen.

## Prerrequisitos típicos

- Instancia de **SQL Server** con autenticación mixta habilitada y servicio reiniciado tras el cambio  
- Carpeta para **SQL Audit** con permisos para la cuenta del servicio SQL  
- Proyecto AVEVA con runtime probado al menos una vez para que existan tablas de histórico antes de `04` y `05`  
- Copias de seguridad y ventana de mantenimiento antes de cambios de permisos o lockdown  

## Referencias normativas y académicas

- FDA **21 CFR Part 11** (registros y firmas electrónicas)  
- Principios de integridad de datos **ALCOA+**  
- Documentación del proyecto: informe final de prácticas, manual técnico V0.2, manual de operación V0.2, propuesta (en la raíz del repo)

## Git y trabajo en equipo

**Repositorio remoto:** [Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos](https://github.com/Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos)

En este repositorio la identidad de commit está definida **solo aquí** (correo UdeA), sin cambiar tu configuración Git global de otros proyectos. Para **subir código con otra cuenta de GitHub** que la del trabajo (SSH, llave y remoto sin mezclar credenciales), sigue la guía:

**[docs/configuracion-git-mac.md](docs/configuracion-git-mac.md)**

```bash
git clone https://github.com/Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos.git
cd "Practica final"
# ... cambios ...
git add -A && git commit -m "Descripción clara del cambio"
git push origin main
```

Convención sugerida: commits en español o inglés, mensaje en una línea que explique el **qué** y el **porqué** breve.

---

*Universidad de Antioquia — Facultad de Ingeniería — Ingeniería de Sistemas. Nova Control S.A.S.*
