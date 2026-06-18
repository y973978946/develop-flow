@echo off
REM Auto configure opencode MCP (Windows)
REM Usage: scripts\setup-mcp.bat [env-file]

setlocal enabledelayedexpansion

set "ENV_FILE=%~1"
if "%ENV_FILE%"=="" set "ENV_FILE=D:\project\178-builder.env"

set "OPENCODE_CONFIG=%USERPROFILE%\.config\opencode\opencode.json"
set "ENV_OUTPUT=%USERPROFILE%\.config\opencode\env.bat"

echo === OpenCode MCP Auto Configuration ===
echo Environment file: %ENV_FILE%

if not exist "%ENV_FILE%" (
    echo ERROR: File not found %ENV_FILE%
    exit /b 1
)

echo.
echo 1. Reading environment variables...

for /f "usebackq tokens=1,* delims==" %%a in ("%ENV_FILE%") do (
    set "line=%%a"
    if not "!line:~0,1!"=="#" (
        set "%%a=%%b"
    )
)

echo Detected configuration:
echo   PostgreSQL: %POSTGRES_HOST%:%POSTGRES_PORT%
echo   Redis: %REDIS_HOST%:%REDIS_PORT%
echo   RabbitMQ: %RABBITMQ_HOST%:%RABBITMQ_PORT%

echo.
echo 2. Creating environment variable file...

if not exist "%USERPROFILE%\.config\opencode" mkdir "%USERPROFILE%\.config\opencode"

(
echo set POSTGRES_HOST=%POSTGRES_HOST%
echo set POSTGRES_PORT=%POSTGRES_PORT%
echo set POSTGRES_USER=%POSTGRES_USER%
echo set POSTGRES_PASSWORD=%POSTGRES_PASSWORD%
echo set POSTGRES_DB=%POSTGRES_DB%
echo set REDIS_HOST=%REDIS_HOST%
echo set REDIS_PORT=%REDIS_PORT%
echo set REDIS_PASSWORD=%REDIS_PASSWORD%
echo set REDIS_DATABASE=%REDIS_DATABASE%
echo set RABBITMQ_HOST=%RABBITMQ_HOST%
echo set RABBITMQ_PORT=%RABBITMQ_PORT%
echo set RABBITMQ_USER=%RABBITMQ_USER%
echo set RABBITMQ_PASSWORD=%RABBITMQ_PASSWORD%
echo set RABBITMQ_VHOST=%RABBITMQ_VHOST%
echo set GITLAB_URL=%GITLAB_URL%
echo set GITLAB_TOKEN=%GITLAB_TOKEN%
echo set GITLAB_PROJECT_ID=%GITLAB_PROJECT_ID%
) > "%ENV_OUTPUT%"

echo   OK: Environment file created: %ENV_OUTPUT%

echo.
echo 3. Creating opencode configuration...

(
echo {
echo   "$schema": "https://opencode.ai/config.json",
echo   "mcp": {
echo     "postgresql": {
echo       "type": "local",
echo       "command": ["npx", "-y", "@modelcontextprotocol/server-postgres"],
echo       "environment": {
echo         "POSTGRES_HOST": "{env:POSTGRES_HOST}",
echo         "POSTGRES_PORT": "{env:POSTGRES_PORT}",
echo         "POSTGRES_USER": "{env:POSTGRES_USER}",
echo         "POSTGRES_PASSWORD": "{env:POSTGRES_PASSWORD}",
echo         "POSTGRES_DATABASE": "{env:POSTGRES_DB}"
echo       },
echo       "enabled": true
echo     },
echo     "redis": {
echo       "type": "local",
echo       "command": ["npx", "-y", "@modelcontextprotocol/server-redis"],
echo       "environment": {
echo         "REDIS_HOST": "{env:REDIS_HOST}",
echo         "REDIS_PORT": "{env:REDIS_PORT}",
echo         "REDIS_PASSWORD": "{env:REDIS_PASSWORD}",
echo         "REDIS_DB": "{env:REDIS_DATABASE}"
echo       },
echo       "enabled": true
echo     },
echo     "rabbitmq": {
echo       "type": "local",
echo       "command": ["npx", "-y", "@modelcontextprotocol/server-rabbitmq"],
echo       "environment": {
echo         "RABBITMQ_HOST": "{env:RABBITMQ_HOST}",
echo         "RABBITMQ_PORT": "{env:RABBITMQ_PORT}",
echo         "RABBITMQ_USER": "{env:RABBITMQ_USER}",
echo         "RABBITMQ_PASSWORD": "{env:RABBITMQ_PASSWORD}",
echo         "RABBITMQ_VHOST": "{env:RABBITMQ_VHOST}"
echo       },
echo       "enabled": true
echo     },
echo     "gitlab": {
echo       "type": "local",
echo       "command": ["npx", "-y", "@modelcontextprotocol/server-gitlab"],
echo       "environment": {
echo         "GITLAB_URL": "{env:GITLAB_URL}",
echo         "GITLAB_TOKEN": "{env:GITLAB_TOKEN}",
echo         "GITLAB_PROJECT_ID": "{env:GITLAB_PROJECT_ID}"
echo       },
echo       "enabled": true
echo     }
echo   }
echo }
) > "%OPENCODE_CONFIG%"

echo   OK: Config file created: %OPENCODE_CONFIG%

echo.
echo 4. Loading environment variables...

call "%ENV_OUTPUT%"

echo   OK: Environment variables loaded

echo.
echo === Configuration Complete ===
echo.
echo Environment variables are ready. You can now start opencode:
echo   opencode
echo.
echo Switch environment:
echo   scripts\setup-mcp.bat D:\project\172-builder.env
echo   scripts\setup-mcp.bat D:\project\178-builder.env

endlocal
