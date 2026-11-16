@echo off
chcp 65001 >nul
setlocal EnableExtensions
title KolinAI - установка PowerShell 7 (последняя версия)
cd /d "%~dp0"

rem ============================================================
rem  PowerShell 7.7.0 (ноябрь 2026) - последняя стабильная.
rem  Ставится в папку ПОЛЬЗОВАТЕЛЯ (без прав администратора!),
rem  системный Windows PowerShell 5.1 остаётся как был.
rem  После установки pwsh доступен в любом терминале.
rem ============================================================

set "PWSH_VER=7.7.0"
set "PZIP=PowerShell-%PWSH_VER%-win-x64.zip"
set "PURL=https://github.com/PowerShell/PowerShell/releases/download/v%PWSH_VER%/%PZIP%"
set "DEST=%LOCALAPPDATA%\PowerShell7"
set "ZTMP=%TEMP%\%PZIP%"

echo ==================================================
echo   KolinAI - установка PowerShell %PWSH_VER%
echo   Куда: %DEST% (без прав администратора)
echo   Вес: около 110 МБ
echo ==================================================
echo.

where curl.exe >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Не найден curl.exe. Нужен Windows 10 1803+ / Windows 11.
    goto :fail
)

if exist "%DEST%\pwsh.exe" (
    for /f "usebackq delims=" %%v in (`"%DEST%\pwsh.exe" -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"`) do set "CURV=%%v"
    echo Уже установлена PowerShell %CURV%.
    if "%CURV%"=="%PWSH_VER%" (
        echo Это и есть последняя версия - обновлять нечего.
        goto :runmenu
    )
    echo Скачаю и обновлю до %PWSH_VER%.
)

echo.
echo Шаг 1 из 2: скачиваю архив %PZIP%...
if exist "%ZTMP%" del /q "%ZTMP%"
curl.exe -L -f -C - --retry 5 --retry-delay 3 --ssl-no-revoke -o "%ZTMP%" "%PURL%"
if errorlevel 1 (
    echo [ОШИБКА] Не скачался. Проверь интернет и запусти батник ещё раз - докачает.
    goto :fail
)

echo Шаг 2 из 2: распаковываю и прописываю в PATH...
if not exist "%DEST%" mkdir "%DEST%" >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%ZTMP%' -DestinationPath '%DEST%' -Force"
if errorlevel 1 (
    echo [ОШИБКА] Архив не распаковался. Запусти ещё раз.
    goto :fail
)
del /q "%ZTMP%" >nul 2>&1

powershell -NoProfile -Command "$p=[Environment]::GetEnvironmentVariable('Path','User'); if($p -notlike '*PowerShell7*'){[Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';')+';%DEST%'), 'User'); echo 'PATH пользователя обновлён'} else {echo 'PATH уже настроен'}"

echo.
for /f "usebackq delims=" %%v in (`"%DEST%\pwsh.exe" -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"`) do echo Установлена PowerShell %%v - готово!

:runmenu
echo.
echo Запуск: любая вкладка терминала пишет "pwsh", или файл:
echo   %DEST%\pwsh.exe
echo Старый Windows PowerShell 5.1 никуда не делся (кнопка "windows powershell").
echo.
set "RUNIT="
set /p RUNIT="Запустить PowerShell 7 сейчас? (Enter = да, n = нет): "
if /i not "%RUNIT%"=="n" "%DEST%\pwsh.exe" -NoLogo
exit /b 0

:fail
echo.
echo Установка не завершена. Запусти батник ещё раз - продолжится с места обрыва.
pause
exit /b 1
