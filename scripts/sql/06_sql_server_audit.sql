/*
  Fase 7 — SQL Server Audit

  1. Crear carpeta en disco (p. ej. C:\SQLAudits\) con permisos para la cuenta de servicio de SQL Server.
  2. Ajustar FILEPATH y el nombre de la base de datos del proyecto.
*/

USE [master];
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_audits WHERE name = N'Auditoria_Seguridad_SCADA')
BEGIN
    CREATE SERVER AUDIT [Auditoria_Seguridad_SCADA]
    TO FILE ( FILEPATH = N'C:\SQLAudits\' )
    WITH ( ON_FAILURE = CONTINUE, QUEUE_DELAY = 1000 );
END
GO

ALTER SERVER AUDIT [Auditoria_Seguridad_SCADA] WITH (STATE = ON);
GO

/* Eventos a nivel de servidor (p. ej. logins fallidos) */
IF NOT EXISTS (SELECT 1 FROM sys.server_audit_specifications WHERE name = N'ServerAuditSpec_SCADA')
BEGIN
    CREATE SERVER AUDIT SPECIFICATION [ServerAuditSpec_SCADA]
    FOR SERVER AUDIT [Auditoria_Seguridad_SCADA]
        ADD (FAILED_LOGIN_GROUP)
    WITH (STATE = ON);
END
GO

/* Permisos y objetos de esquema en la base del SCADA */
USE [DB_SCADA_PROYECTO];
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name = N'DbAuditSpec_SCADA')
BEGIN
    CREATE DATABASE AUDIT SPECIFICATION [DbAuditSpec_SCADA]
    FOR SERVER AUDIT [Auditoria_Seguridad_SCADA]
        ADD (DATABASE_PERMISSION_CHANGE_GROUP),
        ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP)
    WITH (STATE = ON);
END
GO

/*
  Verificación: SSMS → Security → Audits → View Audit Logs.
  Windows: Visor de eventos → Registro de aplicaciones → MSSQLSERVER / ID 33205 según versión.
*/
