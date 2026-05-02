/*
  Recuperación ante bloqueo total (lockout) — SOLO procedimiento de rescate documentado

  No ejecutar como script único. Seguir en CMD elevado y sqlcmd según instancia (ej. .\SQLEXPRESS).

  1) services.msc → detener SQL Server
  2) CMD como administrador:
       net start MSSQL$SQLEXPRESS /m"SQLCMD"
     (reemplazar MSSQL$SQLEXPRESS por el nombre del servicio real)

  3) sqlcmd -S .\SQLEXPRESS -C

  4) En el prompt:
       ALTER LOGIN [Admin_Dba] ENABLE;
       GO
       ALTER SERVER ROLE sysadmin ADD MEMBER [Admin_Dba];
       GO
       EXIT

  5) Detener modo single-user y arrancar servicio normal.
*/
