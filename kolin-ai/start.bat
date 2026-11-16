@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title KolinAI - генератор картинок
cd /d "%~dp0"

set "CANON=%~dp0KolinAI"
set "CBIN=%CANON%\bin"
set "CMODELS=%CANON%\models"
set "CKP=%CMODELS%\checkpoints"

echo ==================================================
echo   KolinAI - запуск
echo   Сам найду движок и модели (рядом с этим файлом,
echo   в Загрузках, на Рабочем столе, в Документах),
echo   сам соберу всё в одну папку и запущусь.
echo ==================================================
echo.

echo Останавливаю старый сервер, если он был запущен...
taskkill /F /IM sd-server.exe >nul 2>&1

echo.
echo Шаг 1: ищу движок sd-server.exe...
set "ENGINE="
for /f "delims=" %%p in ('dir /s /b "%~dp0sd-server.exe" 2^>nul') do if not defined ENGINE set "ENGINE=%%p"

if not defined ENGINE (
    echo     рядом не нашёлся, ищу в Загрузках / на Рабочем столе / в Документах...
    echo     это может занять до минуты, подожди.
    for %%L in ("%USERPROFILE%\Downloads" "%USERPROFILE%\Desktop" "%USERPROFILE%\Documents") do (
        for /f "delims=" %%p in ('dir /s /b "%%~L\sd-server.exe" 2^>nul') do if not defined ENGINE set "ENGINE=%%p"
    )
)

if not defined ENGINE (
    echo.
    echo [!] Движок sd-server.exe не найден вообще.
    echo     Запусти install.bat из этой же папки - он его скачает.
    echo.
    pause
    exit /b 1
)

for %%a in ("%ENGINE%") do set "EBIN=%%~dpa"
echo     найден: !ENGINE!

if not exist "%CBIN%" mkdir "%CBIN%" >nul
if /i not "!EBIN!"=="%CBIN%\" (
    echo     копирую движок в KolinAI\bin...
    copy /y "!EBIN!*.exe" "%CBIN%" >nul
    copy /y "!EBIN!*.dll" "%CBIN%" >nul
)

echo.
echo Шаг 2: собираю модели в KolinAI\models\checkpoints...
if not exist "%CKP%" mkdir "%CKP%" >nul
if not exist "%CMODELS%\vae" mkdir "%CMODELS%\vae" >nul
for %%e in (safetensors sft ckpt gguf) do for /f "delims=" %%f in ('dir /s /b "%~dp0*.%%e" 2^>nul') do call :collect "%%f"

if not exist "%CKP%\*" (
    echo     рядом моделей нет, ищу в Загрузках / на Рабочем столе / в Документах...
    for %%e in (safetensors sft ckpt gguf) do (
        for %%L in ("%USERPROFILE%\Downloads" "%USERPROFILE%\Desktop" "%USERPROFILE%\Documents") do (
            for /f "delims=" %%f in ('dir /s /b "%%~L\*.%%e" 2^>nul') do call :collect "%%f"
        )
    )
)

echo.
if exist "%CKP%\*" (
    echo Модели на месте, сервер их увидит:
    for %%f in ("%CKP%\*") do echo   - %%~nxf  ^(%%~zf байт^)
) else (
    echo [!] Моделей не найдено вообще.
    echo     Сервер запустится, но генерировать не сможет, пока не появится
    echo     модель. Запусти install.bat - он скачает DreamShaper 8.
)

echo.
echo ==================================================
echo   Запускаю сервер. Браузер откроется сам:
echo   http://127.0.0.1:7860
echo   В интерфейсе: кнопка модели -^> Рецепт: SD 1.x
echo   -^> выбери модель -^> "Модели загрузки".
echo   Остановить сервер - закрыть это окно.
echo ==================================================
echo.
start "" cmd /c "timeout /t 4 /nobreak >nul & start "" http://127.0.0.1:7860"
rem Флаги экономии памяти для SDXL на 1024x1024:
rem   --flash-attn on  - резко снижает память механизма внимания
rem   --vae-tiling     - декодирует картинку кусочками (важно при 1024+)
rem Если всё равно падает с ошибкой, добавь в конец строки ниже ещё:
rem   --type q8_0  и/или  --offload-to-cpu
"%CBIN%\sd-server.exe" --model-dir "%CMODELS%" --listen-port 7860 --flash-attn on --vae-tiling

echo.
echo Сервер остановлен.
pause
exit /b 0

:collect
set "FD=%~dp1"
if /i "%FD%"=="%CKP%\" goto :eof
if /i "%FD%"=="%CMODELS%\vae\" goto :eof
set "DST=%CKP%"
echo %~nx1| findstr /i "vae" >nul
if not errorlevel 1 set "DST=%CMODELS%\vae"
echo     переношу: %~nx1
move /y "%~1" "%DST%\%~nx1" >nul 2>&1
goto :eof
