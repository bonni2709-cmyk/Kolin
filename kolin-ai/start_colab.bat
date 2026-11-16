@echo off
chcp 65001 >nul
setlocal EnableExtensions
title KolinAI Colab - картинки без цензуры на бесплатной GPU
cd /d "%~dp0"

set "NBID=1CN1JNnZkIc1HuM8t7DEXhX6Z_EbafLCc"
set "NBFILE=%~dp0kolinai_colab.ipynb"

echo ==================================================
echo   KolinAI Colab - картинки без цензуры на бесплатной GPU
echo   Нужен обычный Google-аккаунт, карта не нужна.
echo   Внутри: Z-Image Turbo (реализм, без фильтра) и
echo   WAI NSFW Illustrious v1.5 (аниме 18+).
echo ==================================================
echo.

where curl.exe >nul 2>nul
if errorlevel 1 (
    echo [ОШИБКА] Не найден curl.exe. Нужен Windows 10 1803+ / Windows 11.
    goto :fail
)

if not exist "%NBFILE%" (
    echo Скачиваю тетрадь...
    curl.exe -L -f --retry 5 --retry-delay 3 --ssl-no-revoke -o "%NBFILE%" "https://drive.google.com/uc?export=download&id=%NBID%"
    if errorlevel 1 (
        echo [ОШИБКА] Не скачалась. Проверь интернет и запусти батник ещё раз.
        goto :fail
    )
)
echo Тетрадь рядом с батником: %NBFILE%
echo.
echo Что делать (займёт пару минут):
echo   1. Сейчас откроется браузер с colab.research.google.com
echo      (не открылся сам - зайди туда вручную, залогинься в Google).
echo   2. Перетащи файл kolinai_colab.ipynb из папки с батником
echo      прямо в окно браузера (или: File - Upload notebook).
echo   3. В тетради: Runtime - Change runtime type - T4 GPU - Save.
echo   4. Runtime - Run all и жди 3-8 минут.
echo   5. Внизу появится ссылка вида https://xxxx.gradio.live -
echo      открой её. Это твой генератор картинок, без цензуры.
echo   6. Картинка скачивается правой кнопкой по ней.
echo.
echo Лимиты: бесплатная GPU - несколько часов в день. Кончилось -
echo завтра снова, или тот же файл в Kaggle (30 часов в неделю):
echo kaggle.com - Create - New Notebook - File - Import notebook -
echo выбрать kolinai_colab.ipynb - включить T4/x2 GPU - Run all.
echo.
echo Запасные генераторы картинок без цензуры (просто ссылки):
echo   AI Horde:  https://aihorde.net   (галочка Allow NSFW в настройках)
echo   Dezgo:     https://dezgo.com     (512x512 без регистрации, безлимит)
echo   Perchance: https://perchance.org/ai-text-to-image-generator
echo.
start "" "https://colab.research.google.com/"
echo Colab открылся. Пользуйся!
echo.
pause
exit /b 0

:fail
echo.
pause
exit /b 1
