/*
  Fase 2 — Logins de servidor y usuario de aplicación SCADA (AVEVA Edge)

  Requisitos:
  - Modo de autenticación mixto habilitado y servicio reiniciado (Fase 1 del manual técnico).
  - Reemplazar <<STRONG_PASSWORD_DBA>> y <<STRONG_PASSWORD_SCADA>> antes de ejecutar.
  - Reemplazar [DB_SCADA_PROYECTO] por el nombre real de la base de datos.
*/

USE [master];
GO

/* 1. Administrador SQL dedicado (mantenimiento SSMS, no uso en runtime AVEVA) */
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'Admin_Dba')
BEGIN
    CREATE LOGIN [Admin_Dba]
        WITH PASSWORD = N'<<STRONG_PASSWORD_DBA>>',
             CHECK_POLICY = ON;
END
GO

ALTER SERVER ROLE [sysadmin] ADD MEMBER [Admin_Dba];
GO

/* 2. Usuario exclusivo para la aplicación SCADA */
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'User_Aveva')
BEGIN
    CREATE LOGIN [User_Aveva]
        WITH PASSWORD = N'<<STRONG_PASSWORD_SCADA>>',
             CHECK_POLICY = ON;
END
GO

USE [DB_SCADA_PROYECTO];
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'User_Aveva')
BEGIN
    CREATE USER [User_Aveva] FOR LOGIN [User_Aveva];
END
GO

ALTER ROLE [db_datareader] ADD MEMBER [User_Aveva];
ALTER ROLE [db_datawriter] ADD MEMBER [User_Aveva];
GO

/* Permite que AVEVA resuelva metadatos (p. ej. grids de alarmas/eventos) */
GRANT VIEW DEFINITION TO [User_Aveva];
GO

GRANT SELECT, INSERT ON SCHEMA::[dbo] TO [User_Aveva];
GO
