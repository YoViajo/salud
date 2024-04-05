@echo off

echo Iniciando respaldo de bases de datos...

REM Obtener la fecha actual
FOR /F "tokens=1,2,3 delims=/ " %%a IN ('DATE /T') DO (
    SET DAY=%%a
    SET MONTH=%%b
    SET YEAR=%%c
)

REM Definir el directorio de respaldo
SET BACKUP_DIR=o:\resp\gamsc-sms\psql_bds\%YEAR%-%MONTH%-%DAY%

REM Verificar si el directorio existe, si no, crearlo
IF NOT EXIST %BACKUP_DIR% (
    MD %BACKUP_DIR%
    echo Directorio de respaldo creado: %BACKUP_DIR%
) ELSE (
    echo El directorio de respaldo ya existe: %BACKUP_DIR%
)

echo Iniciando respaldo de las bases de datos...

REM Realizar los respaldos
"C:\Program Files\PostgreSQL\15\bin\pg_dump" -U postgres -d gamsc-sms -f "%BACKUP_DIR%\gamsc-sms.sql"
IF %ERRORLEVEL% EQU 0 (
    echo Respaldo de gamsc-sms realizado correctamente
) ELSE (
    echo Error al respaldar la base de datos gamsc-sms
)

"C:\Program Files\PostgreSQL\15\bin\pg_dump" -U postgres -d gamsc_epidem -f "%BACKUP_DIR%\gamsc_epidem.sql"
IF %ERRORLEVEL% EQU 0 (
    echo Respaldo de gamsc_epidem realizado correctamente
) ELSE (
    echo Error al respaldar la base de datos gamsc_epidem
)

"C:\Program Files\PostgreSQL\15\bin\pg_dump" -U postgres -d gamsc_planif -f "%BACKUP_DIR%\gamsc_planif.sql"
IF %ERRORLEVEL% EQU 0 (
    echo Respaldo de gamsc_planif realizado correctamente
) ELSE (
    echo Error al respaldar la base de datos gamsc_planif
)

"C:\Program Files\PostgreSQL\15\bin\pg_dump" -U postgres -d guia_urbana -f "%BACKUP_DIR%\guia_urbana.sql"
IF %ERRORLEVEL% EQU 0 (
    echo Respaldo de guia_urbana realizado correctamente
) ELSE (
    echo Error al respaldar la base de datos guia_urbana
)

"C:\Program Files\PostgreSQL\15\bin\pg_dump" -U postgres -d rds_repes -f "%BACKUP_DIR%\rds_repes.sql"
IF %ERRORLEVEL% EQU 0 (
    echo Respaldo de rds_repes realizado correctamente
) ELSE (
    echo Error al respaldar la base de datos rds_repes
)

echo Respaldo de bases de datos completado.