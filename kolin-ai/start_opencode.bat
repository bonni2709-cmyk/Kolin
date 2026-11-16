@echo off
chcp 65001 >nul
setlocal EnableExtensions
title OpenCode
cd /d "%~dp0"

rem ============================================================
rem  OpenCode - бесплатный open-source агент для кода.
rem  Работает в той папке, где лежит этот батник:
rem  хочешь в другом проекте - просто скопируй батник туда.
rem  Внутри программы: /connect - подключить провайдера
rem  (Copilot, OpenRouter, Anthropic...), /models - выбрать модель.
rem ============================================================

set "NODEDIR=%~dp0KolinAI\tools\node"
set "npm_config_prefix=%NODEDIR%"
set "PATH=%NODEDIR%;%PATH%"

if exist "%NODEDIR%\node.exe" goto :nodeok
where node.exe >nul 2>nul
if not errorlevel 1 goto :nodeok

echo Первый запуск: скачиваю Node.js (~30 МБ), ставится рядом, без админа...
if not exist "%NODEDIR%" mkdir "%NODEDIR%" >nul
set "NZIP=node-v22.14.0-win-x64.zip"
set "NTMP=%~dp0KolinAI\tools\node_tmp"
curl.exe -L -f --retry 5 --retry-delay 3 --ssl-no-revoke -o "%NODEDIR%\%NZIP%" "https://nodejs.org/dist/v22.14.0/%NZIP%"
if errorlevel 1 goto :fail
if exist "%NTMP%" rmdir /s /q "%NTMP%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%NODEDIR%\%NZIP%' -DestinationPath '%NTMP%' -Force"
if errorlevel 1 goto :fail
xcopy "%NTMP%\node-v22.14.0-win-x64" "%NODEDIR%\" /E /Y /I >nul
if errorlevel 1 goto :fail
rmdir /s /q "%NTMP%"
del /q "%NODEDIR%\%NZIP%" >nul 2>&1

:nodeok
node --version >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Node.js не запускается. Перезапусти батник.
    goto :fail
)

where opencode >nul 2>nul
if not errorlevel 1 goto :run
echo Устанавливаю OpenCode, пара минут...
call npm install -g opencode-ai
if errorlevel 1 (
    echo [ОШИБКА] Не установился. Проверь интернет и запусти батник ещё раз.
    goto :fail
)

:run
echo Запускаю OpenCode...
call opencode
echo.
pause
exit /b 0

:fail
echo.
pause
exit /b 1
