/*
  Fase 3 — Lockdown inicial de accesos genéricos

  IMPORTANTE:
  - Ejecutar conectado como Admin_Dba (SQL Authentication) tras verificar que Admin_Dba funciona.
  - Deshabilitar manualmente en SSMS el login de Windows del equipo si aplica (Security → Logins → Status → Disabled),
    antes o después según el procedimiento validado en planta.
  - El bloque dinámico deshabilita un login Windows tipo DOMINIO\usuario si existe (ajustar si no aplica).
*/

USE [master];
GO

/* Deshabilitar cuenta sa */
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'sa' AND type = N'S')
    ALTER LOGIN [sa] DISABLE;
GO

/* Opcional: deshabilitar primer login Windows de usuario (revisar en entorno real) */
DECLARE @WinLogin SYSNAME;

SELECT TOP (1) @WinLogin = [name]
FROM sys.server_principals
WHERE [type] = N'U'
  AND [name] LIKE N'%\%'
  AND [name] NOT LIKE N'NT %'
ORDER BY [name];

IF @WinLogin IS NOT NULL
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'ALTER LOGIN ' + QUOTENAME(@WinLogin) + N' DISABLE;';
    EXEC sys.sp_executesql @sql;
    PRINT N'Login Windows deshabilitado: ' + @WinLogin;
END
ELSE
    PRINT N'No se encontró login Windows de usuario para deshabilitar automáticamente.';
GO
