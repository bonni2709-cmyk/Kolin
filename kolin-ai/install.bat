@echo off
chcp 65001 >nul
setlocal EnableExtensions
title KolinAI - установка
cd /d "%~dp0"

set "BASE=%~dp0KolinAI"
set "BIN=%BASE%\bin"
set "MODELS=%BASE%\models"

rem === Версия движка stable-diffusion.cpp ===
set "SD_VER=master-1091-b9d7176"
set "SD_ZIP_URL=https://github.com/leejet/stable-diffusion.cpp/releases/download/%SD_VER%/sd-master-b9d7176-bin-win-vulkan-x64.zip"

rem === Модель по умолчанию: DreamShaper 8, универсальная, без цензуры ===
rem Сервер видит модели только в подпапках: checkpoints\, vae\ и т.д.
set "MODEL_SUB=checkpoints"
set "MODEL_NAME=DreamShaper_8_pruned.safetensors"
set "MODEL_URL=https://huggingface.co/Lykon/DreamShaper/resolve/main/DreamShaper_8_pruned.safetensors"

echo ==================================================
echo   KolinAI - установка генератора картинок
echo   Движок: stable-diffusion.cpp  +  встроенный webUI
echo   Для AMD Vega без NVIDIA, Python не нужен
echo ==================================================
echo.

where curl.exe >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Не найден curl.exe. Нужен Windows 10 версии 1803 или новее / Windows 11.
    goto :fail
)

echo Шаг 1 из 3: создаю папки...
if not exist "%BIN%" mkdir "%BIN%" >nul
if not exist "%MODELS%" mkdir "%MODELS%" >nul
if not exist "%MODELS%\%MODEL_SUB%" mkdir "%MODELS%\%MODEL_SUB%" >nul

if exist "%BIN%\sd-server.exe" goto :model

echo.
echo Шаг 2 из 3: скачиваю движок, примерно 29 МБ...
if exist "%BASE%\sd.zip" del /q "%BASE%\sd.zip"
curl.exe -L -f --retry 5 --retry-delay 3 --ssl-no-revoke -o "%BASE%\sd.zip" "%SD_ZIP_URL%"
if errorlevel 1 (
    echo [ОШИБКА] Не удалось скачать движок. Проверь интернет и запусти install.bat ещё раз.
    goto :fail
)

echo Распаковываю...
if exist "%BASE%\sd_unpacked" rmdir /s /q "%BASE%\sd_unpacked"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%BASE%\sd.zip' -DestinationPath '%BASE%\sd_unpacked' -Force"
if errorlevel 1 (
    echo [ОШИБКА] Не удалось распаковать архив. Запусти install.bat ещё раз.
    goto :fail
)
for /r "%BASE%\sd_unpacked" %%f in (*.exe *.dll) do move /y "%%f" "%BIN%" >nul 2>&1
rmdir /s /q "%BASE%\sd_unpacked"
del /q "%BASE%\sd.zip"

if not exist "%BIN%\sd-server.exe" (
    echo [ОШИБКА] В архиве не нашёлся sd-server.exe. Сообщи об этом - возможно, поменялась структура релиза.
    goto :fail
)
echo Движок установлен.

:model
if exist "%MODELS%\%MODEL_SUB%\%MODEL_NAME%" (
    echo.
    echo Модель %MODEL_SUB%\%MODEL_NAME% уже скачана - пропускаю.
    goto :checkgpu
)

echo.
echo Шаг 3 из 3: скачиваю модель DreamShaper 8, примерно 2 ГБ.
echo НЕ закрывай окно, пока идёт скачивание.
echo Если связь оборвётся - просто запусти install.bat ещё раз, докачка продолжится.
curl.exe -L -f -C - --retry 5 --retry-delay 3 --ssl-no-revoke -o "%MODELS%\%MODEL_SUB%\%MODEL_NAME%.part" "%MODEL_URL%"
if errorlevel 1 (
    echo [ОШИБКА] Скачивание прервано. Запусти install.bat ещё раз - скачивание продолжится с того же места.
    goto :fail
)
move /y "%MODELS%\%MODEL_SUB%\%MODEL_NAME%.part" "%MODELS%\%MODEL_SUB%\%MODEL_NAME%" >nul
echo Модель скачана.

:checkgpu
echo.
echo Проверка видеокарты - список доступных устройств:
"%BIN%\sd-server.exe" --list-devices
echo.
echo Если в списке выше есть слово vulkan - всё отлично, графика будет использоваться.
echo Если там только cpu - обнови драйвер AMD с сайта amd.com и запусти install.bat снова.
echo.
echo ==================================================
echo   ГОТОВО! Запускай start.bat для генерации картинок
echo ==================================================
echo.
pause
exit /b 0

:fail
echo.
echo Установка не завершена. Исправь проблему и запусти install.bat ещё раз.
pause
exit /b 1
