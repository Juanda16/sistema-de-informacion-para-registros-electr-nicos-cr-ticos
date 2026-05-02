/*
  Fase 6 — Inalterabilidad de históricos (21 CFR Part 11)

  Ejecutar DESPUÉS de que AVEVA Edge haya creado las tablas (primera corrida de runtime).
  Ajustar nombres de base de datos y tablas a los generados por el proyecto (Trend*, EventHistory, etc.).

  Efecto: el usuario de aplicación solo puede INSERT; no UPDATE ni DELETE sobre las tablas listadas.
*/

USE [DB_SCADA_PROYECTO];
GO

/* Ejemplos — renombrar según tablas reales en Object Explorer */
DECLARE @ScadaUser SYSNAME = N'User_Aveva';

-- DENY DELETE, UPDATE ON [dbo].[Trend001] TO [User_Aveva];
-- DENY DELETE, UPDATE ON [dbo].[ALARMHISTORY] TO [User_Aveva];
-- DENY DELETE, UPDATE ON [dbo].[EVENTHISTORY] TO [User_Aveva];

/*
Plantilla dinámica (opcional): generar DENY para todas las tablas dbo que coincidan con un prefijo.
Descomentar y ajustar @TableLike si se usa.
*/
/*
DECLARE @TableLike NVARCHAR(128) = N'%HISTORY%';
DECLARE @q NVARCHAR(MAX) = N'';

SELECT @q = @q + N'DENY DELETE, UPDATE ON ' + QUOTENAME(SCHEMA_NAME(schema_id)) + N'.' + QUOTENAME(name)
            + N' TO ' + QUOTENAME(@ScadaUser) + N';' + CHAR(10)
FROM sys.tables
WHERE schema_id = SCHEMA_ID(N'dbo')
  AND name LIKE @TableLike;

EXEC sys.sp_executesql @q;
*/

PRINT N'Revise y descomente las sentencias DENY o la sección dinámica antes de ejecutar en producción.';
GO
