@echo off
chcp 65001 >nul
setlocal EnableExtensions
title KolinAI Text - чат по-русски
cd /d "%~dp0"
set "ROOT=%~dp0"
set "TWORK=%ROOT%KolinAI\text"

echo ============================================
echo   KolinAI Text - локальный чат по-русски
echo   Saiga Nemo 12B, движок llama.cpp
echo ============================================
echo.

rem ---------- 1. Ищу движок (и в bin, и в подпапках) ----------
:setengine
set "ENGINE="
if exist "%TWORK%\bin\llama-server.exe" set "ENGINE=%TWORK%\bin\llama-server.exe"
if not defined ENGINE for /r "%TWORK%" %%f in (llama-server.exe server.exe) do if not defined ENGINE set "ENGINE=%%f"
if not defined ENGINE (
    echo Движок не найден в KolinAI\text.
    if exist "%ROOT%install_text.bat" (
        echo Сейчас запущу установщик: он один раз скачает движок и модель.
        call "%ROOT%install_text.bat"
        echo.
        echo Теперь запусти start_chat.bat ещё раз - всё на месте.
        goto :fail
    )
    echo [ОШИБКА] install_text.bat не найден рядом со start_chat.bat.
    echo Оба батника должны лежать в одной папке.
    goto :fail
)

rem Снимаем метку "файл получен из интернета", если Windows её поставил
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%TWORK%' -Recurse -File | Unblock-File" >nul 2>nul

echo Проверяю движок...
"%ENGINE%" --version >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Файл движка есть, но он не запускается:
    echo   %ENGINE%
    echo Почти наверняка антивирус удалил или заблокировал часть файлов.
    echo Добавь папку KolinAI\text в исключения антивируса
    echo и запусти install_text.bat ещё раз - он перекачает движок.
    goto :fail
)
echo Движок: %ENGINE%
"%ENGINE%" --version

rem ---------- 2. Ищу модель: сначала штатную, потом любой самый крупный .gguf ----------
:setmodel
set "MODEL="
if exist "%TWORK%\models\saiga_nemo_12b.Q4_K_M.gguf" set "MODEL=%TWORK%\models\saiga_nemo_12b.Q4_K_M.gguf"
if not defined MODEL for /f "delims=" %%f in ('dir /b /o-s "%TWORK%\models\*.gguf" 2^>nul') do if not defined MODEL set "MODEL=%TWORK%\models\%%f"
if not defined MODEL (
    echo [ОШИБКА] Модель .gguf не найдена в KolinAI\text\models
    if exist "%TWORK%\models\*.part" (
        echo Там лежит недокачанный файл .part - запусти install_text.bat,
        echo он докачает с того же места.
    ) else (
        echo Запусти install_text.bat - он скачает модель, около 7.5 ГБ.
    )
    goto :fail
)
echo Модель: %MODEL%

rem ---------- 3. Выбираю свободный порт 8080..8100 ----------
set "PORT=8080"
:pickport
set "BUSY="
for /f "delims=" %%l in ('netstat -ano 2^>nul ^| findstr /i /c:"LISTENING" ^| findstr /c:":%PORT% "') do set "BUSY=1"
if defined BUSY (
    set /a PORT+=1
    if %PORT% lss 8100 goto :pickport
)
if not "%PORT%"=="8080" echo Порт 8080 занят - чат поднимется на порту %PORT%.

rem ---------- 4. Убираю прошлый чат-сервер, если висит ----------
echo Останавливаю старый чат-сервер, если был запущен...
taskkill /F /IM llama-server.exe >nul 2>&1

echo.
echo Загрузка модели в память: до минуты. Скорость ответа примерно
echo 3-6 слов в секунду - нормально для 12-миллиардной модели на CPU.
echo ПАМЯТЬ: чату нужно около 9 ГБ. Генератор картинок во время чата
echo запускать нельзя - вместе не влезут.
echo Чтобы остановить чат - просто закрой это окно.
echo Браузер откроется сам, как только модель будет готова.
echo.

rem ---------- 5. Открывалка браузера: ждёт, пока сервер ответит /health ----------
set "OPENER=%TEMP%\kolinai_open_%PORT%.bat"
> "%OPENER%" echo @echo off
>> "%OPENER%" echo curl.exe -s -f -o NUL --noproxy * --retry 90 --retry-delay 2 --retry-connrefused http://127.0.0.1:%PORT%/health
>> "%OPENER%" echo if errorlevel 1 exit /b 1
>> "%OPENER%" echo start "" "http://127.0.0.1:%PORT%"
start "KolinAI opener" /min "%OPENER%"

rem ---------- 6. Сам сервер - в этом окне, ошибки видны ----------
"%ENGINE%" -m "%MODEL%" --host 127.0.0.1 --port %PORT% -c 8192 -t 8

del /q "%OPENER%" >nul 2>&1
echo.
echo Чат-сервер остановлен.
echo Если сервер завершился сам с ошибкой, типичные причины:
echo  - недостаточно свободной ОЗУ: нужно около 9 ГБ, закрой лишние программы;
echo  - антивирус блокирует движок - папку KolinAI\text в исключения;
echo  - модель докачана не до конца - запусти install_text.bat ещё раз.
pause
exit /b 0

:fail
echo.
pause
exit /b 1
