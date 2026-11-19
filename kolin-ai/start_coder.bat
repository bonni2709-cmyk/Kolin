@echo off
chcp 65001 >nul
setlocal EnableExtensions
title KolinAI Code v2 - OpenCode с выбором мозга
cd /d "%~dp0"

set "ROOT=%~dp0"
set "TWORK=%ROOT%KolinAI\text"
set "CWORK=%LOCALAPPDATA%\KolinAI\coder"
set "CBIN=%CWORK%\bin"
set "CMODELS=%CWORK%\models"
set "NODEDIR=%ROOT%KolinAI\tools\node"
set "npm_config_prefix=%NODEDIR%"
set "PATH=%NODEDIR%;%PATH%"

set "LC_VER=b12377"
set "LC_URL=https://github.com/ggml-org/llama.cpp/releases/download/%LC_VER%/llama-%LC_VER%-bin-win-cpu-x64.zip"
set "MODEL_NAME=Qwen2.5-Coder-7B-Instruct-Q4_K_M.gguf"
set "MODEL_URL=https://huggingface.co/bartowski/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/%MODEL_NAME%"
set "ALIAS=qwen2.5-coder-7b"
set "OCDIR=%USERPROFILE%\.config\opencode"

:menu
cls
color 0B
echo ================================================================
echo   KolinAI Code v2 - OpenCode, выбери мозг. Всё бесплатно.
echo   Карта и пополнения нигде не нужны. Проверено: ноябрь 2026.
echo ================================================================
echo.
echo   [1] glhf.chat   - ОБЛАКО: Llama 3.1 70B, 131K контекст
echo                     БЕЗЛИМИТ, ключ за email. РЕКОМЕНДУЮ
echo                     честно: безлимитное бесплатное = небыстрое
echo   [2] NVIDIA NIM  - ОБЛАКО: 82 модели, 40 запросов в МИНУТУ,
echo                     контекст до 1M, ключ за телефон
echo   [3] llm7.io     - ОБЛАКО: DeepSeek R1, вообще без регистрации
echo                     60 запросов в минуту, 100К токенов в сутки
echo   [4] z.ai        - ОБЛАКО: GLM-4.7-Flash, запасной вариант
echo   [5] ЛОКАЛЬНО    - Qwen2.5-Coder 7B на процессоре: офлайн,
echo                     без цензуры, без лимитов, но 2-5 слов в сек
echo.
set "MODE="
set /p MODE="Выбери 1-5 и нажми Enter: "
if not defined MODE goto menu
if "%MODE%"=="1" goto mode1
if "%MODE%"=="2" goto mode2
if "%MODE%"=="3" goto mode3
if "%MODE%"=="4" goto mode4
if "%MODE%"=="5" goto mode5
goto menu

:mode1
set "PROV=glhf"
set "PLABEL=glhf.chat Llama 70B безлимит"
set "BASEURL=https://glhf.chat/api/openai/v1"
set "MODELID=meta-llama/Meta-Llama-3.1-70B-Instruct"
set "MNAME=Llama 3.1 70B"
set "CTX=131072"
set "NEEDKEY=1"
set "KEYURL=https://glhf.chat"
goto common

:mode2
set "PROV=nim"
set "PLABEL=NVIDIA NIM 82 модели"
set "BASEURL=https://integrate.api.nvidia.com/v1"
set "MODELID=nv-mistralai/mistral-nemo-12b-instruct"
set "MNAME=Mistral Nemo 12B"
set "CTX=131072"
set "NEEDKEY=1"
set "KEYURL=https://build.nvidia.com"
goto common

:mode3
set "PROV=llm7"
set "PLABEL=llm7.io DeepSeek без регистрации"
set "BASEURL=https://api.llm7.io/v1"
set "MODELID=deepseek-r1-0528"
set "MNAME=DeepSeek R1"
set "CTX=131072"
set "NEEDKEY=0"
goto common

:mode4
set "PROV=zai"
set "PLABEL=z.ai GLM-4.7-Flash запасной"
set "BASEURL=https://api.z.ai/api/paas/v4"
set "MODELID=glm-4.7-flash"
set "MNAME=GLM 4.7 Flash"
set "CTX=128000"
set "NEEDKEY=1"
set "KEYURL=https://z.ai"
goto common

:mode5
set "LOCALMODE=1"

:common
echo.
echo Шаг 1: проверяю Node.js и OpenCode...
where curl.exe >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Не найден curl.exe. Нужен Windows 10 1803+ / Windows 11.
    goto :fail
)
if exist "%NODEDIR%\node.exe" goto nodeok
where node.exe >nul 2>nul
if not errorlevel 1 goto nodeok
echo Первый запуск: скачиваю Node.js, около 30 МБ, ставится рядом, без админа...
if not exist "%NODEDIR%" mkdir "%NODEDIR%" >nul
set "NZIP=node-v22.14.0-win-x64.zip"
set "NTMP=%ROOT%KolinAI\tools\node_tmp"
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
if not errorlevel 1 goto openok
echo Устанавливаю OpenCode, пара минут...
call npm install -g opencode-ai
if errorlevel 1 (
    echo [ОШИБКА] Не установился. Проверь интернет и запусти батник ещё раз.
    goto :fail
)
:openok
echo OpenCode на месте.

if defined LOCALMODE goto locengine

echo.
if "%NEEDKEY%"=="1" goto needkey
set "KEY=unused"
echo Провайдер без регистрации. Токен с token.llm7.io поднимет лимит -
echo если есть, вставь его, иначе просто нажми Enter.
set "KEY="
set /p KEY="Токен или Enter: "
if not defined KEY set "KEY=unused"
goto keyok

:needkey
echo Этот провайдер требует API-ключ. Он бесплатный, карта не нужна:
echo   1. Открой %KEYURL% и зарегистрируйся
echo   2. Найди раздел API Keys и создай ключ
echo   3. Вставь ключ сюда
set "KEY="
set /p KEY="Вставь ключ и нажми Enter: "
if not defined KEY (
    echo Ключ не введён - без него облако не заработает.
    goto :fail
)

:keyok
echo Проверяю доступ к провайдеру...
curl.exe -s -m 25 -H "Authorization: Bearer %KEY%" "%BASEURL%/models" | findstr /i /c:"id" >nul
if errorlevel 1 (
    echo ВНИМАНИЕ: проверка не прошла - сеть, лимит или сервис временно лежит.
    echo Продолжаю: если модель не заработает, проверь ключ и запусти снова.
)
echo Настраиваю OpenCode на %PLABEL%...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$cfg='%OCDIR%';New-Item -ItemType Directory -Force -Path $cfg|Out-Null;$p=Join-Path $cfg 'opencode.json';$j=$null;try{$j=Get-Content $p -Raw|ConvertFrom-Json}catch{};if(-not $j){$j=New-Object PSObject};$j.PSObject.Properties.Remove('provider');$j.PSObject.Properties.Remove('model');$j.PSObject.Properties.Remove('small_model');$j.PSObject.Properties.Remove('compaction');$m=@{'%MODELID%'=@{name='%MNAME%';limit=@{context=%CTX%;output=8192}}};$prov=@{'%PROV%'=@{npm='@ai-sdk/openai-compatible';name='%PLABEL%';options=@{baseURL='%BASEURL%';apiKey='%KEY%'};models=$m}};$j|Add-Member -Force -Name provider -Value $prov -MemberType NoteProperty;$j|Add-Member -Force -Name model -Value '%PROV%/%MODELID%' -MemberType NoteProperty;$j|Add-Member -Force -Name small_model -Value '%PROV%/%MODELID%' -MemberType NoteProperty;$j|Add-Member -Force -Name compaction -Value @{auto=$true;prune=$true;reserved=8192} -MemberType NoteProperty;[IO.File]::WriteAllText($p,($j|ConvertTo-Json -Depth 12),(New-Object Text.UTF8Encoding($false)))" 2>nul
echo Готово: провайдер %PLABEL%, модель %MNAME%.
echo Если OpenCode ругнётся на имя модели - набери /models и выбери
echo живую модель из списка этого провайдера, список подгружается сам.
echo.
call opencode
echo.
echo Пока!
pause
exit /b 0

:locengine
echo Шаг 2: проверяю движок llama.cpp...
set "ENGINE="
if exist "%TWORK%\bin\llama-server.exe" set "ENGINE=%TWORK%\bin\llama-server.exe"
if not defined ENGINE for /r "%TWORK%" %%f in (llama-server.exe server.exe) do if not defined ENGINE set "ENGINE=%%f"
if not defined ENGINE for /r "%CBIN%" %%f in (llama-server.exe server.exe) do if not defined ENGINE set "ENGINE=%%f"
if defined ENGINE (
    "%ENGINE%" --version >nul 2>nul
    if not errorlevel 1 goto engok
    echo Движок найден, но не запускается - качаю свежий отдельно для кодера...
    set "ENGINE="
)
if not exist "%CWORK%" mkdir "%CWORK%" >nul
if not exist "%CBIN%" mkdir "%CBIN%" >nul
del /q "%CBIN%\*.exe" "%CBIN%\*.dll" >nul 2>&1
if exist "%CWORK%\llc.zip" del /q "%CWORK%\llc.zip"
echo Скачиваю движок llama.cpp %LC_VER%, около 24 МБ...
curl.exe -L -f --retry 5 --retry-delay 3 --ssl-no-revoke -o "%CWORK%\llc.zip" "%LC_URL%"
if errorlevel 1 (
    echo [ОШИБКА] Не удалось скачать движок. Проверь интернет и запусти ещё раз.
    goto :fail
)
if exist "%CWORK%\llc_unp" rmdir /s /q "%CWORK%\llc_unp"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%CWORK%\llc.zip' -DestinationPath '%CWORK%\llc_unp' -Force"
if errorlevel 1 (
    echo [ОШИБКА] Не удалось распаковать архив. Запусти батник ещё раз.
    goto :fail
)
for /r "%CWORK%\llc_unp" %%f in (*.exe *.dll) do move /y "%%f" "%CBIN%" >nul 2>&1
rmdir /s /q "%CWORK%\llc_unp"
del /q "%CWORK%\llc.zip"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath '%CWORK%' -Recurse -File | Unblock-File" >nul 2>nul
set "ENGINE="
for /r "%CBIN%" %%f in (llama-server.exe server.exe) do if not defined ENGINE set "ENGINE=%%f"
if not defined ENGINE (
    echo [ОШИБКА] В архиве не нашёлся llama-server.exe / server.exe.
    goto :fail
)
"%ENGINE%" --version >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Движок скачан, но не запускается. Почти наверняка антивирус.
    echo Добавь папки KolinAI и %LOCALAPPDATA%\KolinAI в исключения антивируса
    echo и запусти батник ещё раз.
    goto :fail
)
:engok
echo Движок: %ENGINE%

echo Шаг 3: проверяю модель...
if not exist "%CMODELS%" mkdir "%CMODELS%" >nul
if exist "%CMODELS%\%MODEL_NAME%" (
    echo Модель уже скачана.
    goto modelok
)
if exist "%CMODELS%\%MODEL_NAME%.part" echo Найдена недокачанная модель - продолжу с того же места.
echo Скачиваю Qwen2.5-Coder 7B, около 4.7 ГБ - только в первый раз.
echo НЕ закрывай окно. При обрыве просто запусти батник ещё раз - докачается.
curl.exe -L -f -C - --retry 5 --retry-delay 3 --ssl-no-revoke -o "%CMODELS%\%MODEL_NAME%.part" "%MODEL_URL%"
if errorlevel 1 (
    echo [ОШИБКА] Скачивание прервано. Запусти батник ещё раз - продолжится с того же места.
    goto :fail
)
move /y "%CMODELS%\%MODEL_NAME%.part" "%CMODELS%\%MODEL_NAME%" >nul
:modelok
echo Модель: %CMODELS%\%MODEL_NAME%

echo Шаг 4: настраиваю OpenCode и запускаю...
set "PORT=8180"
:pickport
set "BUSY="
for /f "delims=" %%l in ('netstat -ano 2^>nul ^| findstr /i /c:"LISTENING" ^| findstr /c:":%PORT% "') do set "BUSY=1"
if defined BUSY (
    set /a PORT+=1
    if %PORT% lss 8210 goto :pickport
)
if not "%PORT%"=="8180" echo Порт 8180 занят - сервер встанет на %PORT%.
echo Останавливаю старый сервер нейронки, если был...
taskkill /F /IM llama-server.exe >nul 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -Command "$cfg='%OCDIR%';New-Item -ItemType Directory -Force -Path $cfg|Out-Null;$p=Join-Path $cfg 'opencode.json';$j=$null;try{$j=Get-Content $p -Raw|ConvertFrom-Json}catch{};if(-not $j){$j=New-Object PSObject};$j.PSObject.Properties.Remove('provider');$j.PSObject.Properties.Remove('model');$j.PSObject.Properties.Remove('small_model');$j.PSObject.Properties.Remove('compaction');$m=@{'%ALIAS%'=@{name='Qwen2.5 Coder 7B';limit=@{context=32768;output=8192}}};$prov=@{'kolinai-local'=@{npm='@ai-sdk/openai-compatible';name='KolinAI Local';options=@{baseURL='http://127.0.0.1:%PORT%/v1'};models=$m}};$j|Add-Member -Force -Name provider -Value $prov -MemberType NoteProperty;$j|Add-Member -Force -Name model -Value 'kolinai-local/%ALIAS%' -MemberType NoteProperty;$j|Add-Member -Force -Name small_model -Value 'kolinai-local/%ALIAS%' -MemberType NoteProperty;$j|Add-Member -Force -Name compaction -Value @{auto=$true;prune=$true;reserved=8192} -MemberType NoteProperty;[IO.File]::WriteAllText($p,($j|ConvertTo-Json -Depth 12),(New-Object Text.UTF8Encoding($false)))" 2>nul
echo OpenCode настроен: модель KolinAI Local выберется сама.

echo Запускаю сервер нейронки в отдельном окне...
start "KolinAI coder" /min "%ENGINE%" -m "%CMODELS%\%MODEL_NAME%" --host 127.0.0.1 --port %PORT% -c 32768 -t 8 --alias %ALIAS%
echo Жду, пока модель загрузится в память, до минуты...
curl.exe -s -f -o NUL --noproxy * --retry 90 --retry-delay 2 --retry-connrefused http://127.0.0.1:%PORT%/health
if errorlevel 1 (
    echo [ОШИБКА] Сервер не поднялся. Смотри свёрнутое окно KolinAI coder:
    echo типичные причины - мало свободной ОЗУ, нужно около 7 ГБ, или антивирус.
    goto :fail
)
echo Модель готова. Запускаю OpenCode...
echo ПАМЯТЬ: кодер занимает около 7 ГБ - чат и картинки одновременно не запускать.
echo В OpenCode: модель выбрана сама, смена - /models, провайдер KolinAI Local.
echo.
call opencode

echo.
set "KEEP="
set /p KEEP="Enter - остановить сервер нейронки, K - оставить работать: "
if /i "%KEEP%"=="K" (
    echo Сервер продолжает работать в свёрнутом окне KolinAI coder, порт %PORT%.
) else (
    taskkill /F /IM llama-server.exe >nul 2>&1
    echo Сервер остановлен.
)
echo Пока!
pause
exit /b 0

:fail
echo.
echo Запуск не завершён. Исправь проблему и запусти батник ещё раз.
pause
exit /b 1