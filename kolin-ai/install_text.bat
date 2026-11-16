@echo off
chcp 65001 >nul
setlocal EnableExtensions
title KolinAI Text - установка текстовой нейронки
cd /d "%~dp0"

set "ROOT=%~dp0"
set "TB=%ROOT%KolinAI\text\bin"
set "TMODELS=%ROOT%KolinAI\text\models"
set "TWORK=%ROOT%KolinAI\text"

rem === Версия llama.cpp (движок) ===
set "LC_VER=b12377"
set "LC_URL=https://github.com/ggml-org/llama.cpp/releases/download/%LC_VER%/llama-%LC_VER%-bin-win-cpu-x64.zip"

rem === Модель: Saiga Nemo 12B (русская, от Ильи Гусева, Apache-2.0) ===
rem Mistral-Nemo 12B, дообучена на русских диалогах; отказов минимум.
set "MODEL_NAME=saiga_nemo_12b.Q4_K_M.gguf"
set "MODEL_URL=https://huggingface.co/IlyaGusev/saiga_nemo_12b_gguf/resolve/main/%MODEL_NAME%"

rem === Старая модель, которую удаляем ===
set "OLD_MODEL=Qwen2.5-7B-Instruct-abliterated-v2.Q4_K_M.gguf"

echo ==================================================
echo   KolinAI Text - установка текстовой нейронки
echo   Saiga Nemo 12B: заточена под РУССКИЙ язык,
echo   отказов минимум. Работает на процессоре.
echo   Скачивание около 7.5 ГБ - только в первый раз.
echo ==================================================
echo.

where curl.exe >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Не найден curl.exe. Нужен Windows 10 1803+ / Windows 11.
    goto :fail
)

echo Шаг 1 из 3: создаю папки...
if not exist "%TB%" mkdir "%TB%" >nul
if not exist "%TMODELS%" mkdir "%TMODELS%" >nul

if exist "%TMODELS%\%OLD_MODEL%" (
    echo Удаляю старую модель Qwen - освободится около 4.7 ГБ...
    del /q "%TMODELS%\%OLD_MODEL%"
)

rem ---------- Движок: ищем установленный, проверяем, чиним ----------
set "ENGINE="
for /r "%TB%" %%f in (llama-server.exe server.exe) do if not defined ENGINE set "ENGINE=%%f"

if defined ENGINE (
    echo Найден движок: %ENGINE%
    call :smoke
    if not errorlevel 1 (
        echo Движок работает, пропускаю скачивание.
        goto :model
    )
    echo Движок есть, но не запускается - обычно это антивирус удалил часть файлов.
    echo Перекачиваю движок заново...
    del /q "%TB%\*.exe" "%TB%\*.dll" >nul 2>&1
    set "ENGINE="
)

echo.
echo Шаг 2 из 3: скачиваю движок llama.cpp %LC_VER%, около 24 МБ...
if exist "%TWORK%\llc.zip" del /q "%TWORK%\llc.zip"
curl.exe -L -f --retry 5 --retry-delay 3 --ssl-no-revoke -o "%TWORK%\llc.zip" "%LC_URL%"
if errorlevel 1 (
    echo [ОШИБКА] Не удалось скачать движок. Проверь интернет и запусти install_text.bat ещё раз.
    goto :fail
)
echo Распаковываю...
if exist "%TWORK%\llc_unp" rmdir /s /q "%TWORK%\llc_unp"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%TWORK%\llc.zip' -DestinationPath '%TWORK%\llc_unp' -Force"
if errorlevel 1 (
    echo [ОШИБКА] Не удалось распаковать архив. Запусти install_text.bat ещё раз.
    goto :fail
)
for /r "%TWORK%\llc_unp" %%f in (*.exe *.dll) do move /y "%%f" "%TB%" >nul 2>&1
rmdir /s /q "%TWORK%\llc_unp"
del /q "%TWORK%\llc.zip"

set "ENGINE="
for /r "%TB%" %%f in (llama-server.exe server.exe) do if not defined ENGINE set "ENGINE=%%f"
if not defined ENGINE (
    echo [ОШИБКА] В архиве не нашёлся llama-server.exe / server.exe.
    echo Содержимое папки bin:
    dir /b "%TB%" 2>nul
    goto :fail
)

rem Снимаем метку "файл получен из интернета"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%TWORK%' -Recurse -File | Unblock-File" >nul 2>nul

rem Проверка: движок реально стартует (ловит антивирус и битые dll сразу, а не в чате)
call :smoke
if errorlevel 1 (
    echo [ОШИБКА] Движок скачан, но не запускается. Почти наверняка антивирус
    echo заблокировал файлы. Добавь папку KolinAI\text в исключения антивируса
    echo и запусти install_text.bat ещё раз.
    goto :fail
)
echo Движок установлен и проверен:
"%ENGINE%" --version

:model
if exist "%TMODELS%\%MODEL_NAME%" (
    echo.
    echo Модель %MODEL_NAME% уже скачана - пропускаю.
    goto :done
)

echo.
echo Шаг 3 из 3: скачиваю модель Saiga Nemo 12B, около 7.5 ГБ.
echo НЕ закрывай окно, пока идёт скачивание.
echo При обрыве просто запусти install_text.bat ещё раз - докачка продолжится.
curl.exe -L -f -C - --retry 5 --retry-delay 3 --ssl-no-revoke -o "%TMODELS%\%MODEL_NAME%.part" "%MODEL_URL%"
if errorlevel 1 (
    echo [ОШИБКА] Скачивание прервано. Запусти install_text.bat ещё раз - продолжится с того же места.
    goto :fail
)
move /y "%TMODELS%\%MODEL_NAME%.part" "%TMODELS%\%MODEL_NAME%" >nul
echo Модель скачана.

:done
echo.
echo ==================================================
echo   ГОТОВО! Запускай start_chat.bat для чата
echo   Браузер откроется сам, когда модель загрузится.
echo ==================================================
echo.
echo Память: чат занимает около 9 ГБ. Генератор картинок
echo (SDXL) во время чата запускать нельзя - не влезут вместе.
echo.
pause
exit /b 0

:smoke
"%ENGINE%" --version >nul 2>nul
exit /b %errorlevel%

:fail
echo.
echo Установка не завершена. Исправь проблему и запусти install_text.bat ещё раз.
pause
exit /b 1
