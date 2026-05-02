/*
  Verificación de integridad de filas (checksums)

  Cómo funciona:
  - RowChecksum es una columna calculada PERSISTED = BINARY_CHECKSUM(columnas...).
  - SQL Server guarda ese entero en la fila y lo actualiza en cada INSERT/UPDATE legal.
  - Si los datos de esas columnas se alteran fuera del motor (corrupción o edición
    directa del almacenamiento), el valor guardado en RowChecksum suele dejar de
    coincidir con BINARY_CHECKSUM(...) recalculado al leer la fila.

  Limitaciones:
  - BINARY_CHECKSUM no es criptográfico (no sustituye HMAC/SHA); sirve para detección
    operativa y pruebas tipo OQ, no contra un atacante con control total del archivo.
  - La expresión en este script debe ser idéntica a la de 05_add_row_checksum_columns.sql.

  Uso: ejecutar en SSMS; MismatchRowCount debe ser 0. El segundo resultado por tabla
  lista hasta 500 filas sospechosas (vacío si no hay discrepancias).

  Nota: el protocolo OQ del proyecto también valida detección desde AVEVA (alarma);
  este script es la verificación directa en base de datos.
*/

USE [DB_SCADA_PROYECTO];
GO

SET NOCOUNT ON;

/* ---- EVENTHISTORY ---- */
IF OBJECT_ID(N'[dbo].[EVENTHISTORY]', N'U') IS NOT NULL
   AND EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE object_id = OBJECT_ID(N'[dbo].[EVENTHISTORY]')
          AND name = N'RowChecksum'
   )
BEGIN
    ;WITH Evaluated AS (
        SELECT
            e.*,
            BINARY_CHECKSUM([Ev_Time], [Ev_User], [Ev_Value], [Ev_Message]) AS [RecalculatedChecksum]
        FROM [dbo].[EVENTHISTORY] AS e
    )
    SELECT N'EVENTHISTORY' AS [TableName], COUNT(*) AS [MismatchRowCount]
    FROM Evaluated AS x
    WHERE NOT (
        x.[RowChecksum] = x.[RecalculatedChecksum]
        OR (x.[RowChecksum] IS NULL AND x.[RecalculatedChecksum] IS NULL)
    );

    ;WITH Evaluated AS (
        SELECT
            e.*,
            BINARY_CHECKSUM([Ev_Time], [Ev_User], [Ev_Value], [Ev_Message]) AS [RecalculatedChecksum]
        FROM [dbo].[EVENTHISTORY] AS e
    )
    SELECT TOP (500) N'EVENTHISTORY' AS [TableName], x.*
    FROM Evaluated AS x
    WHERE NOT (
        x.[RowChecksum] = x.[RecalculatedChecksum]
        OR (x.[RowChecksum] IS NULL AND x.[RecalculatedChecksum] IS NULL)
    )
    ORDER BY x.[Ev_Time];
END
ELSE
    PRINT N'EVENTHISTORY: tabla o columna RowChecksum no existe; omitir o ejecutar 05_add primero.';
GO

/* ---- ALARMHISTORY ---- */
IF OBJECT_ID(N'[dbo].[ALARMHISTORY]', N'U') IS NOT NULL
   AND EXISTS (
        SELECT 1
        FROM sys.columns
        WHERE object_id = OBJECT_ID(N'[dbo].[ALARMHISTORY]')
          AND name = N'RowChecksum'
   )
BEGIN
    ;WITH Evaluated AS (
        SELECT
            a.*,
            BINARY_CHECKSUM([Al_Start_Time], [Al_Tag], [Al_Message], [Al_User]) AS [RecalculatedChecksum]
        FROM [dbo].[ALARMHISTORY] AS a
    )
    SELECT N'ALARMHISTORY' AS [TableName], COUNT(*) AS [MismatchRowCount]
    FROM Evaluated AS x
    WHERE NOT (
        x.[RowChecksum] = x.[RecalculatedChecksum]
        OR (x.[RowChecksum] IS NULL AND x.[RecalculatedChecksum] IS NULL)
    );

    ;WITH Evaluated AS (
        SELECT
            a.*,
            BINARY_CHECKSUM([Al_Start_Time], [Al_Tag], [Al_Message], [Al_User]) AS [RecalculatedChecksum]
        FROM [dbo].[ALARMHISTORY] AS a
    )
    SELECT TOP (500) N'ALARMHISTORY' AS [TableName], x.*
    FROM Evaluated AS x
    WHERE NOT (
        x.[RowChecksum] = x.[RecalculatedChecksum]
        OR (x.[RowChecksum] IS NULL AND x.[RecalculatedChecksum] IS NULL)
    )
    ORDER BY x.[Al_Start_Time];
END
ELSE
    PRINT N'ALARMHISTORY: tabla o columna RowChecksum no existe; omitir o ejecutar 05_add primero.';
GO
