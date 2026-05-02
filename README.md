# Sistema de información para registros electrónicos críticos (TPS/MIS)

**Práctica profesional — Ingeniería de Sistemas, Universidad de Antioquia**

Proyecto desarrollado en colaboración entre la **Universidad de Antioquia** y **Nova Control S.A.S.** (Medellín): diseño, implementación y validación de un sistema de información alineado con **FDA 21 CFR Part 11** e integridad de datos (**ALCOA+**), sobre la plataforma **SCADA AVEVA Edge** y **Microsoft SQL Server**, en el contexto de la envasadora de polvos **All-Fill**.

## Autores

- Laura Cecilia Tobón Ospina  
- Juan David Arismendy Pulgarín  

**Asesor UdeA:** Jaime Humberto Fonseca Espinal  
**Asesor en empresa:** Manuel Mauricio Goez Mora (Nova Control S.A.S.)

## Confidencialidad

Parte del contenido (informe, manuales y detalles de planta) está marcado como **confidencial** frente a terceros. Este repositorio **público** incluye solo código y documentación genérica del enfoque técnico; **no** se versionan aquí el informe, manuales ni notas personales de configuración (permanecen en copia local o en un medio privado acordado con UdeA/Nova Control). No exponer credenciales, IPs ni datos de producción en issues ni commits.

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
├── README.md
├── .gitignore
├── scripts/
│   ├── sql/                  # Scripts T-SQL (orden sugerido por prefijo)
│   └── powershell/           # Blindaje NTFS carpeta de datos SQL
└── aveva/                    # Reservado para exportes del SCADA (opcional; no subir secretos)
```

La carpeta **`docs/`** (notas personales de Git/Mac) y los **PDF/DOCX confidenciales** no se suben al remoto público; quedan solo en tu máquina si los conservas fuera de Git o en un **repositorio privado** aparte.

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
- Documentación académica y de empresa (informe, manuales V0.2, propuesta): **no** están en este remoto público; consultar copias locales o el canal acordado con la universidad y Nova Control.

## Git y trabajo en equipo

**Repositorio remoto:** [Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos](https://github.com/Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos)

Para clonar, colaborar y autenticación SSH con varias cuentas en el mismo Mac, usa la documentación oficial de GitHub: [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) y [Managing multiple accounts](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-your-personal-account/managing-multiple-accounts). En tu clon local puedes fijar `git config user.name` y `user.email` solo en esa carpeta (sin tocar el `~/.gitconfig` global).

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
