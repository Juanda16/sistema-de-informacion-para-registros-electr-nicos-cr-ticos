# Sistema de información para registros electrónicos críticos (TPS/MIS)

**Práctica profesional — Ingeniería de Sistemas, Universidad de Antioquia**

Proyecto desarrollado en colaboración entre la **Universidad de Antioquia** y **Nova Control S.A.S.** (Medellín): diseño, implementación y validación de un sistema de información alineado con **FDA 21 CFR Part 11** e integridad de datos (**ALCOA+**), sobre la plataforma **SCADA AVEVA Edge** y **Microsoft SQL Server**, en el contexto de la envasadora de polvos **All-Fill**.

## Autores

- Laura Cecilia Tobón Ospina  
- Juan David Arismendy Pulgarín  

**Asesor UdeA:** Jaime Humberto Fonseca Espinal  
**Asesor en empresa:** Manuel Mauricio Goez Mora (Nova Control S.A.S.)

## Confidencialidad

El informe de prácticas, los manuales de operación y técnico, y la documentación contractual asociada están sujetos a restricciones de difusión acordadas con Nova Control S.A.S. y la universidad. Este repositorio público contiene únicamente material técnico genérico (scripts y descripción del enfoque). No incluir en issues ni en commits credenciales, direcciones internas, datos de producción ni archivos marcados como confidenciales.

## Objetivo

Convertir datos operativos (alarmas, eventos, setpoints, acciones de operador) en **registros electrónicos íntegros y auditables**: capa de captura tipo **TPS**, reportes y trazabilidad tipo **MIS**, con controles de seguridad, **firma electrónica**, **audit trail** en SQL Server, restricciones de alteración y borrado, auditoría de servidor y endurecimiento del sistema operativo según el diseño validado en planta.

## Stack

| Componente | Rol |
|------------|-----|
| **AVEVA Edge** | SCADA/HMI, requisitos Part 11, firmas electrónicas, persistencia hacia SQL |
| **Microsoft SQL Server** | Históricos, políticas de acceso, SQL Audit |
| **Windows** | Estación industrial; permisos NTFS sobre datos SQL; servicio gateway AVEVA |
| **PLC / proceso** | Integración con la línea All-Fill (Schneider, Mitsubishi, variador, servo, entre otros) |

La propuesta inicial consideraba SQLite; en la implementación se adoptó **SQL Server** por concurrencia, permisos granulares, auditoría de motor y alineación con entornos corporativos.

## Contenido del repositorio

| Ruta | Contenido |
|------|-----------|
| `scripts/sql/` | Scripts T-SQL numerados: creación de logins, lockdown, `DENY` sobre históricos, checksums, auditoría SQL, notas de recuperación |
| `scripts/powershell/` | Script de restricción de ACL sobre la carpeta de datos de SQL Server |
| `aveva/` | Carpeta reservada para artefactos opcionales del proyecto SCADA (no versionar secretos ni credenciales) |

Material académico y corporativo completo (informe, manuales V0.2, propuesta) no forma parte de este remoto público; su custodia corresponde a los canales definidos por la UdeA y la empresa.

## Uso de los scripts SQL

Ejecutar en **SQL Server Management Studio** u otra herramienta equivalente, previa revisión de nombres de base de datos, rutas y sustitución de placeholders de contraseña. Aplicar solo en entornos de prueba o tras protocolo interno (IQ/OQ).

| Archivo | Descripción |
|---------|-------------|
| `01_create_database_template.sql` | Plantilla de creación de base de datos |
| `02_create_logins_and_scada_user.sql` | Logins de administración y de aplicación SCADA, roles y permisos mínimos |
| `03_lockdown_disable_windows_and_sa.sql` | Deshabilitación de `sa` y ajuste de logins Windows según procedimiento |
| `04_deny_update_delete_historical_tables.sql` | `DENY DELETE/UPDATE` sobre tablas de histórico (ajustar nombres reales) |
| `05_add_row_checksum_columns.sql` | Columnas `RowChecksum` (`BINARY_CHECKSUM` persistido) |
| `05_verify_row_checksums.sql` | Comprobación de coherencia checksum almacenado vs recalculado |
| `06_sql_server_audit.sql` | Auditoría a archivo y especificaciones de servidor y base de datos |
| `99_emergency_sql_recovery_notes.sql` | Procedimiento de rescate ante bloqueo de cuentas (referencia, no ejecutar como script ciego) |

**PowerShell:** `scripts/powershell/Lockdown-SqlDataDirectory.ps1` restringe ACL sobre la carpeta de datos de SQL Server; requiere ejecución elevada y ruta validada para la instancia.

La configuración detallada de pantallas, tags y conexión en **AVEVA Edge** reside en el proyecto del SCADA; no se duplica aquí.

## Prerrequisitos

- SQL Server con autenticación mixta habilitada y servicio reiniciado tras el cambio  
- Carpeta para archivos de **SQL Audit** con permisos para la cuenta del servicio SQL  
- Al menos una ejecución de runtime AVEVA que cree las tablas de histórico antes de aplicar `04` y `05`  
- Respaldo y ventana de mantenimiento antes de cambios de permisos o lockdown  

## Referencias

- FDA, [21 CFR Part 11](https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfcfr/CFRSearch.cfm?CFRPart=11) (registros y firmas electrónicas)  
- Principios de integridad de datos **ALCOA+** y guías GxP aplicables al sector regulado  

## Repositorio y colaboración

Código y documentación técnica de este trabajo: [github.com/Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos](https://github.com/Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos)

```bash
git clone https://github.com/Juanda16/sistema-de-informacion-para-registros-electr-nicos-cr-ticos.git
cd sistema-de-informacion-para-registros-electr-nicos-cr-ticos
```

Para autenticación SSH y gestión de varias identidades en GitHub, la documentación oficial es la referencia: [Conexión con SSH](https://docs.github.com/es/authentication/connecting-to-github-with-ssh) y [Varias cuentas](https://docs.github.com/es/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-your-personal-account/managing-multiple-accounts).

Los colaboradores pueden usar `git config` **local** al repositorio (`user.name`, `user.email`) según la política de la universidad o del laboratorio, sin modificar la configuración global del equipo.

---

*Universidad de Antioquia — Facultad de Ingeniería — Ingeniería de Sistemas. Nova Control S.A.S.*
