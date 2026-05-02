/*
  Fase 6.3 — Columnas calculadas persistidas (checksum de fila)

  Objetivo: detectar manipulación fuera de la aplicación (integridad 11.10(c)).
  Ajustar nombres de columnas si el esquema AVEVA difiere en esta instalación.

  Verificación en SQL: ejecutar después 05_verify_row_checksums.sql (compara valor
  persistido vs recálculo). En planta, el informe OQ también contempla validación
  desde AVEVA (alarma de corrupción) además de esta comprobación en BD.
*/

USE [DB_SCADA_PROYECTO];
GO

IF OBJECT_ID(N'[dbo].[EVENTHISTORY]', N'U') IS NOT NULL
   AND NOT EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE object_id = OBJECT_ID(N'[dbo].[EVENTHISTORY]')
          AND name = N'RowChecksum'
   )
BEGIN
    ALTER TABLE [dbo].[EVENTHISTORY]
    ADD [RowChecksum] AS (BINARY_CHECKSUM([Ev_Time], [Ev_User], [Ev_Value], [Ev_Message])) PERSISTED;
    PRINT N'RowChecksum añadido a EVENTHISTORY.';
END
GO

IF OBJECT_ID(N'[dbo].[ALARMHISTORY]', N'U') IS NOT NULL
   AND NOT EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE object_id = OBJECT_ID(N'[dbo].[ALARMHISTORY]')
          AND name = N'RowChecksum'
   )
BEGIN
    ALTER TABLE [dbo].[ALARMHISTORY]
    ADD [RowChecksum] AS (BINARY_CHECKSUM([Al_Start_Time], [Al_Tag], [Al_Message], [Al_User])) PERSISTED;
    PRINT N'RowChecksum añadido a ALARMHISTORY.';
END
GO
