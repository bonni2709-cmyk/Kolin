#!/bin/bash
# ============================================================
#  KolinAI Cloud: ComfyUI + PornWorks и другие модели без цензуры
#  Куда вставлять: терминал Linux-сервера с NVIDIA GPU
#  (Cloud.ru / Lightning AI / Vast.ai / RunPod / Hyperbolic, Ubuntu 22.04/24.04)
#  Просто скопируй ВЕСЬ этот текст и вставь в терминал (Ctrl+Shift+V).
#  Скачивает около 30 ГБ, занимает 20-40 минут. При обрыве - вставь ещё раз.
# ============================================================
set -e
cd "$HOME"

echo "=== Шаг 0/5: базовые пакеты ==="
sudo apt-get update -qq 2>/dev/null || true
sudo apt-get install -y git python3-venv curl 2>/dev/null || true

echo "=== Шаг 1/5: ставлю ComfyUI ==="
if [ ! -d ComfyUI ]; then
  git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git
fi
cd ComfyUI

if [ ! -d venv ]; then
  python3 -m venv venv
fi
PIP=./venv/bin/pip
$PIP install --upgrade pip -q
$PIP install torch torchvision --index-url https://download.pytorch.org/whl/cu121 -q
$PIP install -r requirements.txt -q

echo "=== Шаг 2/5: качаю модели (около 30 ГБ, наберись терпения) ==="
mkdir -p models/checkpoints models/vae
dl() {
  if [ ! -f "$2" ]; then
    echo "   качаю $2 ..."
    curl -L -f --retry 5 -C - -o "$2.part" "$1"
    mv "$2.part" "$2"
  else
    echo "   $2 уже есть - пропускаю"
  fi
}
# --- PornWorks (официальные чекпойнты, выложенные сообществом на HuggingFace) ---
# Real Porn v04 - реалистичные фото, SDXL/Pony-семейство (6.9 ГБ)
dl "https://huggingface.co/AI-Porn/pornworks-real-porn-photo-realistic-nsfw-sdxl-and-pony-chekpoint/resolve/main/pornworksRealPornPhoto_v04.safetensors" \
   "models/checkpoints/pornworksRealPornPhoto_v04.safetensors"
# Anime Desire v02 - аниме/хентай, SDXL (6.9 ГБ)
dl "https://huggingface.co/AI-Porn/pornworks-anime-desire-NSFW-Anime-and-hentai-sdxl-checkpoint/resolve/main/pornworksAnimeDesireNSFW_v02.safetensors" \
   "models/checkpoints/pornworksAnimeDesireNSFW_v02.safetensors"
# Nude People - Flux.1 dev, всё в одном файле (11.9 ГБ) - максимальное качество
dl "https://huggingface.co/AI-Porn/pornworks-nude-people-photo-realistic-nsfw-flux-1d-checkpoint/resolve/main/pornworksNudePeoplePhoto_02.safetensors" \
   "models/checkpoints/pornworksNudePeoplePhoto_02.safetensors"
# --- Дополнительно ---
# Juggernaut XL v9 Photo - чистый фотореализм (6.9 ГБ)
dl "https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors" \
   "models/checkpoints/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors"
# Realistic Vision 6 - быстрые черновики SD 1.5 (2 ГБ) + VAE
dl "https://huggingface.co/SG161222/Realistic_Vision_V6.0_B1_noVAE/resolve/main/Realistic_Vision_V6.0_NV_B1_fp16.safetensors" \
   "models/checkpoints/Realistic_Vision_V6.0_NV_B1_fp16.safetensors"
dl "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors" \
   "models/vae/vae-ft-mse-840000-ema-pruned.safetensors"

echo "=== Шаг 3/5: проверка видеокарты ==="
nvidia-smi || echo "(!) nvidia-smi не найден - возможно, сервер без GPU. Проверь выбор машины."

echo "=== Шаг 4/5: создаю ярлык запуска ==="
cat > "$HOME/start_comfyui.sh" << 'EOF'
#!/bin/bash
cd "$HOME/ComfyUI"
./venv/bin/python main.py --listen 0.0.0.0 --port 8188
EOF
chmod +x "$HOME/start_comfyui.sh"

echo ""
echo "============================================================"
echo "=== Шаг 5/5: ЗАПУСК. Открывай в браузере порт 8188 ==="
echo "  Адрес: http://<IP-адрес-сервера>:8188"
echo "  (в панели Cloud.ru открой входящий порт TCP 8188)"
echo "  Остановить: Ctrl+C. Запустить снова: bash ~/start_comfyui.sh"
echo ""
echo "  МОДЕЛИ В НОДЕ Load Checkpoint:"
echo "   * pornworksRealPornPhoto_v04   - PornWorks, реалистичные фото (основная)"
echo "   * pornworksNudePeoplePhoto_02  - PornWorks FLUX, макс качество"
echo "   * pornworksAnimeDesireNSFW_v02 - PornWorks, аниме/хентай"
echo "   * Juggernaut XL v9             - чистый фотореализм"
echo "   * Realistic Vision 6           - быстрые черновики"
echo ""
echo "  НАСТРОЙКИ для PornWorks Real Porn (SDXL/Pony):"
echo "   Промпт: score_9, score_8_up, score_7_up, дальше текст сцены,"
echo "   в конце rating:explicit, professional photo, 4k, sharp focus"
echo "   Негатив: score_6, score_5, score_4, longbody, lowres, bad anatomy,"
echo "   bad hands, worst quality, low quality, anime, 3d, text, deformed,"
echo "   mutated, ugly, child, teen"
echo "   KSampler: steps 25-30, cfg 6-7, euler a (или dpmpp_2m + karras),"
echo "   размер 832x1216 или 1024x1024."
echo ""
echo "  НАСТРОЙКИ для FLUX (pornworksNudePeoplePhoto_02):"
echo "   Промпт обычным текстом, негатив НЕ нужен,"
echo "   KSampler: steps 20, cfg 1, euler, scheduler simple, 1024x1024."
echo "============================================================"
echo ""
./venv/bin/python main.py --listen 0.0.0.0 --port 8188
