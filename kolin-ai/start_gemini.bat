@echo off
chcp 65001 >nul
setlocal EnableExtensions
title KolinAI Code - Gemini CLI (агент кода от Google)
cd /d "%~dp0"

rem ============================================================
rem  Gemini CLI: агент-программист от Google в терминале.
rem  Бесплатно с личным Google-аккаунтом (вход по OAuth в браузере):
rem  примерно 60 запросов/мин и 1000 запросов/день, модели Gemini 3,
rem  контекст 1 000 000 токенов. Карта не нужна.
rem  ВНИМАНИЕ: Google может блокировать сервис по региону - из РФ/РБ
rem  может не пустить; решение как быть - на твоей совести.
rem  Альтернатива входу: ключ GEMINI_API_KEY из aistudio.google.com.
rem ============================================================

set "NODEDIR=%~dp0KolinAI\tools\node"
set "npm_config_prefix=%NODEDIR%"
set "PATH=%NODEDIR%;%PATH%"

echo ==================================================
echo   KolinAI Code - Gemini CLI (Google)
echo   Бесплатно: ~60 запросов/мин, ~1000/день
echo   Модели Gemini 3, контекст 1M токенов
echo ==================================================
echo.

echo Шаг 1: проверяю Node.js (нужен для установки)...
if exist "%NODEDIR%\node.exe" goto :nodeok
where node.exe >nul 2>nul
if not errorlevel 1 goto :nodeok

echo Скачиваю Node.js 22 (~30 МБ), ставится в KolinAI\tools\node без админа...
if not exist "%NODEDIR%" mkdir "%NODEDIR%" >nul
set "NZIP=node-v22.14.0-win-x64.zip"
set "NTMP=%~dp0KolinAI\tools\node_tmp"
curl.exe -L -f --retry 5 --retry-delay 3 --ssl-no-revoke -o "%NODEDIR%\%NZIP%" "https://nodejs.org/dist/v22.14.0/%NZIP%"
if errorlevel 1 (
    echo [ОШИБКА] Node.js не скачался. Запусти start_gemini.bat ещё раз.
    goto :fail
)
if exist "%NTMP%" rmdir /s /q "%NTMP%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%NODEDIR%\%NZIP%' -DestinationPath '%NTMP%' -Force"
if errorlevel 1 (
    echo [ОШИБКА] Архив Node.js не распаковался. Запусти ещё раз.
    goto :fail
)
xcopy "%NTMP%\node-v22.14.0-win-x64" "%NODEDIR%\" /E /Y /I >nul
if errorlevel 1 (
    echo [ОШИБКА] Не удалось скопировать файлы Node.js.
    goto :fail
)
rmdir /s /q "%NTMP%"
del /q "%NODEDIR%\%NZIP%" >nul 2>&1
echo Node.js установлен.

:nodeok
node --version >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Node.js не запускается. Перезапусти start_gemini.bat.
    goto :fail
)

echo Шаг 2: проверяю Gemini CLI...
call gemini --version >nul 2>nul
if errorlevel 1 (
    echo Устанавливаю Gemini CLI, это несколько минут...
    call npm install -g @google/gemini-cli
    if errorlevel 1 (
        echo [ОШИБКА] Gemini CLI не установился. Проверь интернет, запусти ещё раз.
        goto :fail
    )
)
for /f "delims=" %%v in ('call gemini --version 2^>nul') do echo Gemini CLI %%v готов.

echo.
echo Где лежит твой проект? Введи путь к папке и Enter.
echo Просто Enter = работать в папке рядом с батником.
set "PROJ="
set /p PROJ="Путь: "
if defined PROJ set "PROJ=%PROJ:"=%"
if defined PROJ cd /d "%PROJ%" 2>nul
if not exist "%CD%" (
    echo [ОШИБКА] Папка не найдена.
    goto :fail
)

echo.
echo При первом запуске выбери в меню "Login with Google" -
echo откроется браузер, войди в обычный Google-аккаунт. Это бесплатный тариф.
echo Дальше просто пиши агенту, что сделать с кодом. Выход: Ctrl+C дважды или /quit.
echo.
call gemini

:end
echo.
pause
exit /b 0

:fail
echo.
pause
exit /b 1
