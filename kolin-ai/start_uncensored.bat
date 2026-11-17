@echo off
chcp 65001 >nul
title KolinAI — Текст без цензуры в облаке (бесплатно, ноябрь 2026)
setlocal
color 0B
:menu
cls
echo ================================================================
echo   KolinAI — БЕСПЛАТНЫЙ ТЕКСТ В ОБЛАКЕ, МИНИМУМ ЦЕНЗУРЫ
echo   Проверено: ноябрь 2026. Карты и пополнений нигде не нужно.
echo   Лучшие варианты собраны здесь — выбирай цифру.
echo ================================================================
echo.
echo   [1] DeepSeek чат        - БЕЗЛИМИТ сообщений, слабые фильтры
echo                             ЛУЧШИЙ бесплатный текст вообще
echo   [2] glhf.chat           - БЕЗЛИМИТНЫЙ API Llama 3.1 70B и Mixtral
echo                             ключ за email, без карты, OpenAI-совместимый
echo   [3] OpenRouter :free    - Venice Uncensored + Hermes 405B в free-ротации
echo                             50 запросов в день, без карты
echo   [4] NVIDIA NIM          - 82 модели, 40 запросов в МИНУТУ, до 1M контекст
echo                             ключ за телефон, без карты
echo   [5] llm7.io             - DeepSeek V4 Flash и R1, без регистрации
echo                             60 запросов в минуту, 100К токенов в сутки
echo   [6] AI Horde текст      - безлимит и без цензуры, очередь волонтёров
echo   [7] SpicyChat           - веб-ролеплей 18+ без фильтров, безлимит
echo   [8] LMArena             - frontier-модели Claude/GPT/Gemini бесплатно
echo   [9] z.ai                - запасной GLM-чат (держим в голове)
echo.
echo   [I] Инструкция: подключить всё это к SillyTavern и OpenAI-клиентам
echo   [T] Тест AI Horde прямо из батника
echo   [0] Выход
echo.
set /p CH="Выбери и нажми Enter: "
if not defined CH goto menu
if "%CH%"=="1" goto o1
if "%CH%"=="2" goto o2
if "%CH%"=="3" goto o3
if "%CH%"=="4" goto o4
if "%CH%"=="5" goto o5
if "%CH%"=="6" goto o6
if "%CH%"=="7" goto o7
if "%CH%"=="8" goto o8
if "%CH%"=="9" goto o9
if /i "%CH%"=="I" goto instr
if /i "%CH%"=="T" goto horde
if "%CH%"=="0" goto bye
goto menu

:o1
start "" https://chat.deepseek.com
goto menu

:o2
start "" https://glhf.chat
goto menu

:o3
start "" "https://openrouter.ai/models?max_price=0"
goto menu

:o4
start "" https://build.nvidia.com
goto menu

:o5
start "" https://llm7.io
goto menu

:o6
start "" https://lite.koboldai.net
goto menu

:o7
start "" https://spicychat.ai
goto menu

:o8
start "" https://lmarena.ai
goto menu

:o9
start "" https://chat.z.ai
goto menu

:horde
echo.
echo Тест AI Horde — проверяем, жив ли сервер...
curl -s -m 25 https://aihorde.net/api/v2/status_check
echo.
echo Если выше написано ok — Horde жив. Текст генерируют модели волонтёров,
echo очередь может занять от минуты до десяти.
pause
goto menu

:instr
echo.
echo ============ КАК ПОДКЛЮЧИТЬ (OpenAI-совместимые клиенты) ============
echo.
echo В SillyTavern: вкладка API — Chat Completion — Custom OpenAI-compatible,
echo вставь Base URL и ключ, модель выбери из списка.
echo.
echo --- OpenRouter: Venice Uncensored и Hermes 405B, 50 запр/д бесплатно ---
echo   Base URL: https://openrouter.ai/api/v1
echo   Ключ:     openrouter.ai — вкладка Keys — Create Key
echo   Модель:   в списке моделей включи фильтр цены 0 и ищи
echo             Venice Uncensored или Hermes 3 405B Instruct
echo   Опция, НЕ обязательна: разовые 10 долл поднимают лимит до 1000 запр/д
echo.
echo --- NVIDIA NIM: 82 модели, 40 запр/мин, до 1M контекста ---
echo   Base URL: https://integrate.api.nvidia.com/v1
echo   Ключ:     build.nvidia.com — Get API Key (нужен только телефон)
echo   Модель:   смотри каталог на build.nvidia.com, например
echo             nv-mistralai/mistral-nemo-12b-instruct
echo.
echo --- glhf.chat: БЕЗЛИМИТ, Llama 3.1 70B ---
echo   Base URL: https://glhf.chat/api/openai/v1
echo   Ключ:     glhf.chat — регистрация по email — вкладка API Keys
echo   Модель:   meta-llama/Meta-Llama-3.1-70B-Instruct
echo.
echo --- AI Horde: безлимит, без цензуры, ключ-заглушка ---
echo   Base URL: https://oai.aihorde.net/v1
echo   Ключ:     0000000000  (анонимный; tools не поддерживаются)
echo   Модель:   любую из списка GET /v1/models
echo.
echo --- llm7.io: без регистрации, 60 запр/мин, 100К ток/день ---
echo   Base URL: https://api.llm7.io/v1
echo   Ключ:     токен со страницы token.llm7.io или слово unused
echo   Модель:   deepseek-v4-flash, deepseek-r1-0528 и ещё 30+
echo.
echo ============ ПОХОРОНЕННЫЕ (не трать время) ============
echo Yupp.ai закрылся в апреле 2026 — давал 800+ frontier-моделей бесплатно.
echo ElectronHub: в 2025 давал 100К кредитов в день, с 2026 — 0.25 долл в неделю.
echo NanoGPT: free-модель только на сайте, API — только за деньги.
echo Grok free: 10 сообщений за 2 часа — скудно, фильтры на месте.
echo Mancer free: MythoLite 2019 года — музей.
echo.
pause
goto menu

:bye
endlocal
exit /b
