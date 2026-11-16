#!/bin/bash
# ============================================================
#  KolinAI Music (облако) — ACE-Step: ПОЛНОЦЕННЫЕ ПЕСНИ С ВОКАЛОМ,
#  в том числе НА РУССКОМ ЯЗЫКЕ. Длительность до 10 минут,
#  генерация за секунды. Лицензия MIT.
#
#  Это для арендованной GPU-машины (immers.cloud / Cloud.ru,
#  RTX 3090 / 4090, примерно 70–90 руб/час).
#
#  Как пользоваться:
#   1. Арендуй машину с NVIDIA GPU (Ubuntu 22.04, образ с PyTorch/CUDA).
#   2. Открой веб-консоль машины (терминал) и вставь туда весь текст
#      этого скрипта, нажми Enter. Либо: bash server_setup_music.sh
#   3. Установка ~10–15 минут. Потом скрипт сам запустит веб-интерфейс,
#      модель скачается с HuggingFace при первом запуске (~10 ГБ).
#   4. Найди в консоли строку "Running on public URL" — это ссылка,
#      открой её в браузере своего ноутбука. Пиши тему песни, текст
#      и стиль — получай готовый трек с вокалом.
#   5. Файлы — кнопкой Download в интерфейсе.
#   6. ЗАКОНЧИЛ — ВЫКЛЮЧАЙ МАШИНУ (деньги считаются по часам!).
# ============================================================
set -e
echo "=== KolinAI Music: установка ACE-Step ==="
if ! command -v git >/dev/null 2>&1; then
  apt-get update && apt-get install -y git
fi
cd ~
if [ -d ACE-Step ]; then
  (cd ACE-Step && git pull)
else
  git clone https://github.com/ace-step/ACE-Step.git
fi
cd ACE-Step
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo
echo "Установка завершена. Запускаю веб-интерфейс на порту 7860..."
echo "Ищи строку 'Running on public URL' и открой ссылку в браузере."
echo "Если публичной ссылки нет — открой http://IP_ЭТОЙ_МАШИНЫ:7860"
echo "Остановка интерфейса: Ctrl+C. Не забудь выключить машину!"
echo
python app.py --port 7860 --share
