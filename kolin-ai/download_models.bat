@echo off
chcp 65001 >nul
setlocal EnableExtensions
title KolinAI - дополнительные модели
cd /d "%~dp0"

set "MODELS=%~dp0KolinAI\models"
if not exist "%MODELS%" mkdir "%MODELS%" >nul
if not exist "%MODELS%\checkpoints" mkdir "%MODELS%\checkpoints" >nul
if not exist "%MODELS%\vae" mkdir "%MODELS%\vae" >nul

echo Модели для скачивания, все без цензуры:
echo.
echo   --- ОРИГИНАЛЬНЫЕ PornWorks (HuggingFace, аккаунт AI-Porn) ---
echo   [1] PornWorks Real Porn v04 - реалистичные фото, SDXL, около 7 ГБ
echo   [2] PornWorks Anime Desire v02 - аниме/хентай, SDXL, около 7 ГБ
echo   [3] PornWorks Nude People (Flux, всё в одном) - МАКС качество,
echo       около 12 ГБ. НА ЭТОМ НОУТЕ БУДЕТ ОЧЕНЬ МЕДЛЕННО (30-60+ мин),
echo       лучше для облачного сервера!
echo.
echo   --- Аналоги и базовые ---
echo   [4] CyberRealistic Pony GGUF - лёгкий аналог PW, около 5 ГБ
echo   [5] Juggernaut XL v9 Photo - чистый фотореализм, около 7 ГБ
echo   [6] Pony Diffusion V6 XL - база Pony, около 7 ГБ
echo   [7] Realistic Vision V6.0 - быстрые черновики SD 1.5, около 2 ГБ
echo   [8] AbyssOrangeMix2 Hard - аниме SD 1.5, около 2 ГБ
echo.
echo   [9] Выход
echo.
choice /c 123456789 /n /m "Что скачать: "
if errorlevel 9 goto :end
if errorlevel 8 goto :aom
if errorlevel 7 goto :rv
if errorlevel 6 goto :pony
if errorlevel 5 goto :jug
if errorlevel 4 goto :crp
if errorlevel 3 goto :pwflux
if errorlevel 2 goto :pwanime
if errorlevel 1 goto :pwreal

:pwreal
echo.
echo PornWorks Real Porn v04 - официальный чекпойнт сервиса, выложенный
echo на HuggingFace. База: SDXL/Pony-семейство. Качается около 7 ГБ.
call :get "checkpoints\pornworksRealPornPhoto_v04.safetensors" "https://huggingface.co/AI-Porn/pornworks-real-porn-photo-realistic-nsfw-sdxl-and-pony-chekpoint/resolve/main/pornworksRealPornPhoto_v04.safetensors"
echo.
echo ГОТОВО. В веб-интерфейсе: Рецепт = SDXL, этот файл, VAE = Нет.
echo На этом ноуте: 10-25 минут на картинку (это SDXL).
echo.
echo ПРОМПТ (формат Pony): начинай со строк
echo   score_9, score_8_up, score_7_up,
echo дальше обычным текстом описывай сцену (по-английски), в конце теги
echo   rating:explicit, professional photo, 4k, sharp focus
echo НЕГАТИВ:
echo   score_6, score_5, score_4, longbody, lowres, bad anatomy, bad hands,
echo   missing fingers, extra digit, cropped, worst quality, low quality,
echo   anime, cartoon, 3d, render, text, deformed, mutated, ugly, child, teen
echo НАСТРОЙКИ: 832x1216 или 1024x1024, Эйлер А, шаги 25-30, CFG 6-7.
goto :end

:pwanime
echo.
echo PornWorks Anime Desire v02 - аниме/хентай, SDXL. Качается около 7 ГБ.
call :get "checkpoints\pornworksAnimeDesireNSFW_v02.safetensors" "https://huggingface.co/AI-Porn/pornworks-anime-desire-NSFW-Anime-and-hentai-sdxl-checkpoint/resolve/main/pornworksAnimeDesireNSFW_v02.safetensors"
echo.
echo ГОТОВО. В веб-интерфейсе: Рецепт = SDXL, этот файл, VAE = Нет.
echo ПРОМПТ: danbooru-теги через запятую (1girl, long_hair, ...),
echo для откровенного: rating:explicit, uncensored.
echo НЕГАТИВ: (worst quality, mutated hands and fingers, bad anatomy:1.2),
echo watermark, signature, child, teen
echo НАСТРОЙКИ: 832x1216 или 1024x1024, Эйлер А, шаги 25, CFG 6.
goto :end

:pwflux
echo.
echo ВНИМАНИЕ! PornWorks Nude People - это FLUX, файл около 12 ГБ.
echo На этом ноутбуке: загрузка в память занимает 5-10 минут и почти
echo забивает 16 ГБ ОЗУ, картинка 30-60+ минут. Рекомендуется только
echo на облачном сервере (server_setup.sh ставит его сам).
echo.
choice /c YN /n /m "Всё равно качать на ноут? (Y/N): "
if errorlevel 2 goto :end
call :get "checkpoints\pornworksNudePeoplePhoto_02.safetensors" "https://huggingface.co/AI-Porn/pornworks-nude-people-photo-realistic-nsfw-flux-1d-checkpoint/resolve/main/pornworksNudePeoplePhoto_02.safetensors"
echo.
echo ГОТОВО. В веб-интерфейсе: Рецепт = FLUX (не SDXL!), этот файл, VAE = Нет.
echo Промпт - обычный текст на английском, без score_тегов.
echo НЕГАТИВ не нужен. Настройки: CFG 1, Эйлер, шаги 20, 1024x1024.
goto :end

:crp
echo.
echo CyberRealistic Pony GGUF - облегчённый аналог PornWorks (та же
echo Pony-база). Качается около 5 ГБ.
call :get "checkpoints\CyberRealisticPony_V12.7-vae_f16-q5_0.gguf" "https://huggingface.co/Green-Sky/CyberRealisticPony-GGUF/resolve/main/CyberRealisticPony_V12.7-vae_f16-q5_0.gguf"
echo.
echo ГОТОВО. В веб-интерфейсе: Рецепт = SDXL, этот GGUF-файл, VAE = Нет.
echo ПРОМПТ: score_9, score_8_up, score_7_up, source_photo, raw photo, ...
echo НЕГАТИВ: score_6, score_5, score_4, worst quality, low quality,
echo watermark, text, censored, deformed, bad anatomy, child, teen
echo НАСТРОЙКИ: 832x1216, Эйлер А, шаги 25, CFG 7.
goto :end

:jug
echo.
echo Juggernaut XL v9 Photo - топовый чистый фотореализм. Около 7 ГБ.
call :get "checkpoints\Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors"
echo.
echo ГОТОВО. В веб-интерфейсе: Рецепт = SDXL, этот файл.
echo Дефолты рецепта: 1024x1024, CFG 5, Эйлер, 20 шагов.
goto :end

:pony
echo.
echo Pony Diffusion V6 XL - базовая модель Pony. Около 7 ГБ.
call :get "checkpoints\ponyDiffusionV6XL_v6StartWithThisOne.safetensors" "https://huggingface.co/LyliaEngine/Pony_Diffusion_V6_XL/resolve/main/ponyDiffusionV6XL_v6StartWithThisOne.safetensors"
call :get "vae\sdxl_vae.safetensors" "https://huggingface.co/LyliaEngine/Pony_Diffusion_V6_XL/resolve/main/sdxl_vae.safetensors"
echo.
echo ГОТОВО. Рецепт = SDXL; VAE = sdxl_vae.safetensors (если серо-жёлтая).
echo ПРОМПТ: score_9, score_8_up, score_7_up, ...
goto :end

:rv
call :get "checkpoints\Realistic_Vision_V6.0_NV_B1_fp16.safetensors" "https://huggingface.co/SG161222/Realistic_Vision_V6.0_B1_noVAE/resolve/main/Realistic_Vision_V6.0_NV_B1_fp16.safetensors"
call :get "vae\vae-ft-mse-840000-ema-pruned.safetensors" "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors"
echo.
echo ГОТОВО. Рецепт = SD 1.x; VAE = vae-ft-mse-840000-ema-pruned (обязательно).
goto :end

:aom
call :get "checkpoints\AbyssOrangeMix2_hard_pruned_fp16_with_VAE.safetensors" "https://huggingface.co/WarriorMama777/OrangeMixs/resolve/main/Models/AbyssOrangeMix2/Pruned/AbyssOrangeMix2_hard_pruned_fp16_with_VAE.safetensors"
echo.
echo ГОТОВО. Рецепт = SD 1.x, VAE = Нет.
goto :end

:get
set "OUT=%MODELS%\%~1"
set "URL=%~2"
if exist "%OUT%" (
    echo Файл %~1 уже скачан - пропускаю.
    goto :eof
)
echo.
echo Скачиваю %~1 ...
echo НЕ закрывай окно, пока идёт скачивание. При обрыве просто запусти батник ещё раз.
curl.exe -L -f -C - --retry 5 --retry-delay 3 --ssl-no-revoke -o "%OUT%.part" "%URL%"
if errorlevel 1 (
    echo [ОШИБКА] Скачивание прервано. Запусти download_models.bat ещё раз - оно продолжится с того же места.
    goto :eof
)
move /y "%OUT%.part" "%OUT%" >nul
echo Скачано: %~1
goto :eof

:end
echo.
pause
