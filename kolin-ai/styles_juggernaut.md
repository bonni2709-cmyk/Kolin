# 20 стилевых пресетов под Juggernaut XL v9 (RunDiffusion Photo) — с полными негативами

Как пользоваться: возьми «Промпт», вставь свой сюжет вместо [СЮЖЕТ] (по-английски),
вбей «Негатив» целиком в Negative prompt, выставь CFG/Шаги/Размер из «Настроек».
Базовый сэмплер почти везде: **dpm++ 2m + karras** (в ui: Method = dpm++2m,
Scheduler = karras). Исключения помечены.

---

## ФОТО-СТИЛИ

### 1. Реалистичное фото
- Промпт: `professional photograph, [СЮЖЕТ], natural skin texture, detailed skin pores, sharp focus, 85mm lens, shallow depth of field, high quality, 4k`
- Негатив: `cartoon, anime, 3d render, painting, illustration, deformed, bad anatomy, bad hands, extra fingers, worst quality, low quality, jpeg artifacts, watermark, text, signature, blurry, plastic skin, airbrushed`
- Настройки: CFG 5 · 25 шагов · 1024×1024 или 832×1216

### 2. Портрет в студии
- Промпт: `studio portrait of [СЮЖЕТ], softbox lighting, dark gray backdrop, professional retouch, catchlight in eyes, 85mm f/1.4, bokeh, editorial quality`
- Негатив: `cartoon, anime, 3d render, painting, illustration, deformed face, asymmetric eyes, bad hands, extra fingers, worst quality, low quality, jpeg artifacts, watermark, text, blurry, plastic skin, oversaturated`
- Настройки: CFG 5.5 · 30 шагов · 832×1216

### 3. Кинематографичный кадр
- Промпт: `cinematic still, [СЮЖЕТ], dramatic lighting, film grain, anamorphic lens, moody atmosphere, color graded, movie scene, 35mm, shot on ARRI, high budget`
- Негатив: `cartoon, anime, illustration, 3d render, video game screenshot, flat lighting, oversaturated, low quality, worst quality, deformed, bad anatomy, watermark, text, letterboxing`
- Настройки: CFG 6 · 30 шагов · 1024×576 (16:9) или 1024×1024

### 4. Плёнка 90-х (Kodak Portra)
- Промпт: `analog film photo, [СЮЖЕТ], kodak portra 400, film grain, slight vignette, warm tones, nostalgic, candid, imperfect focus, 90s aesthetic`
- Негатив: `cartoon, anime, 3d render, digital art, oversaturated, hdr, modern smartphone photo, sharp digital edges, deformed, bad anatomy, worst quality, low quality, jpeg artifacts, watermark, text`
- Настройки: CFG 4.5 · 25 шагов · 832×1216

### 5. Чёрно-белая классика
- Промпт: `black and white photograph, [СЮЖЕТ], high contrast, dramatic shadows, monochrome, fine art photography, timeless`
- Негатив: `color, colored, sepia, cartoon, anime, 3d render, painting, low quality, worst quality, deformed, bad anatomy, watermark, text, blurry`
- Настройки: CFG 5 · 25 шагов · 1024×1024

### 6. Уличная фотография
- Промпт: `street photography, [СЮЖЕТ], candid moment, urban environment, natural light, documentary style, 35mm, motion blur background`
- Негатив: `cartoon, anime, 3d render, painting, posed studio photo, plastic skin, oversharpened, low quality, worst quality, deformed, bad anatomy, watermark, text`
- Настройки: CFG 5 · 25 шагов · 1024×1024

### 7. Фэшн-съёмка (журнальная)
- Промпт: `editorial fashion photography, [СЮЖЕТ], vogue magazine style, high fashion, professional lighting, elegant pose, luxury aesthetic, ultra detailed fabric`
- Негатив: `cartoon, anime, 3d render, painting, amateur, cheap looking, cluttered background, deformed, bad anatomy, bad hands, extra fingers, asymmetric face, worst quality, low quality, jpeg artifacts, watermark, text`
- Настройки: CFG 6 · 30 шагов · 832×1216

### 8. Макро
- Промпт: `extreme macro photography, [СЮЖЕТ], macro lens 100mm, extreme detail, water droplets, bokeh background, nature, crisp focus`
- Негатив: `cartoon, anime, painting, illustration, 3d render, dirty, dust, out of focus, oversaturated, low quality, worst quality, deformed, watermark, text`
- Настройки: CFG 5 · 25 шагов · 1024×1024

### 9. Продуктовая съёмка
- Промпт: `professional product photography, [СЮЖЕТ], studio lighting, white background, commercial shot, advertising, ultra sharp, reflections`
- Негатив: `cartoon, anime, painting, cluttered background, dirty, fingerprints, jpeg artifacts, low quality, worst quality, blurry, deformed, watermark, text`
- Настройки: CFG 6 · 25 шагов · 1024×1024

### 10. Эпичный пейзаж
- Промпт: `breathtaking landscape, [СЮЖЕТ], golden hour, epic vista, volumetric light, hyperdetailed, national geographic, wide angle, atmospheric perspective`
- Негатив: `people, buildings, urban, flat lighting, oversaturated, cartoon, anime, painting, illustration, low quality, worst quality, blurry, watermark, text`
- Настройки: CFG 5.5 · 30 шагов · 1216×832 (горизонт)

---

## ХУДОЖЕСТВЕННЫЕ СТИЛИ

### 11. Масляная живопись
- Промпт: `oil painting, [СЮЖЕТ], thick impasto brush strokes, canvas texture, rich colors, classical art, painted by master artist, museum quality`
- Негатив: `photo, photograph, photorealistic, 3d render, cgi, digital art, anime, cartoon, low quality, worst quality, blurry, watermark, text, signature, frame, border`
- Настройки: CFG 6.5 · 30 шагов · 1024×1024

### 12. Скетчбук
- Промпт: `sketchbook drawing, [СЮЖЕТ], pencil sketch, graphite, hatching, loose lines, paper texture, hand drawn, sketch study, monochrome pencil`
- Негатив: `photo, photograph, realistic, color, painting, oil painting, 3d render, digital art, anime, low quality, worst quality, watermark, text, signature, blurry`
- Настройки: CFG 7 · 25 шагов · 1024×1024 · (можно Method euler_a)

### 13. Акварель
- Промпт: `watercolor painting, [СЮЖЕТ], soft washes of color, wet on wet technique, paper texture, delicate, artistic, light and airy`
- Негатив: `photo, photograph, photorealistic, 3d render, digital art, anime, oil painting, thick paint, low quality, worst quality, blurry, watermark, text, frame, border`
- Настройки: CFG 7 · 28 шагов · 1024×1024 · (euler_a тоже хорош)

### 14. Цифровая иллюстрация
- Промпт: `digital illustration, [СЮЖЕТ], vibrant colors, detailed background, artstation trending, concept art style, dramatic composition`
- Негатив: `photo, photograph, low quality, worst quality, deformed, bad anatomy, bad hands, extra fingers, jpeg artifacts, watermark, text, signature, blurry`
- Настройки: CFG 6 · 30 шагов · 1024×1024

### 15. Фэнтези-арт
- Промпт: `epic fantasy art, [СЮЖЕТ], magical atmosphere, glowing particles, intricate details, dramatic sky, epic scale, fantasy painting`
- Негатив: `photo, photograph, modern, flat lighting, low quality, worst quality, deformed, bad anatomy, bad hands, jpeg artifacts, watermark, text, blurry`
- Настройки: CFG 6.5 · 30 шагов · 1024×1024 или 832×1216

### 16. Концепт-арт персонажа
- Промпт: `character concept art, [СЮЖЕТ], full body, character sheet, design details, neutral background, professional concept artist, detailed outfit`
- Негатив: `photo, photograph, cropped, cut off, out of frame, low quality, worst quality, deformed, bad anatomy, extra limbs, watermark, text, blurry`
- Настройки: CFG 6 · 30 шагов · 832×1216

### 17. Аниме-иллюстрация
- Промпт: `anime illustration, [СЮЖЕТ], clean lineart, cel shading, vibrant colors, detailed eyes, anime key visual, studio quality`
- Негатив: `photo, photorealistic, 3d, realistic, western cartoon, sketch, rough lines, low quality, worst quality, deformed, bad hands, extra fingers, watermark, text, blurry`
- Настройки: CFG 6 · 25 шагов · 832×1216 · **Method euler_a**

### 18. Комикс / графическая новелла
- Промпт: `comic book art, [СЮЖЕТ], bold ink outlines, flat colors, halftone shading, graphic novel panel, dynamic composition`
- Негатив: `photo, photorealistic, 3d, realistic, anime, sketch, unfinished, low quality, worst quality, deformed, bad anatomy, watermark, text, blurry`
- Настройки: CFG 7 · 25 шагов · 1024×1024

### 19. Неон / киберпанк
- Промпт: `cyberpunk scene, [СЮЖЕТ], neon lights, rain reflections, futuristic city, blade runner atmosphere, volumetric fog, night, moody`
- Негатив: `daylight, rural, countryside, flat lighting, oversaturated, low quality, worst quality, deformed, bad anatomy, watermark, text, blurry`
- Настройки: CFG 6 · 30 шагов · 1024×1024

### 20. Флэт-вектор / минимализм
- Промпт: `flat vector illustration, [СЮЖЕТ], minimalist design, clean shapes, limited color palette, simple background, modern poster art`
- Негатив: `photo, photograph, photorealistic, 3d, gradients, complex details, texture, noise, sketch, low quality, worst quality, watermark, text, blurry`
- Настройки: CFG 7 · 25 шагов · 1024×1024

---

## Общие правила для Juggernaut XL v9

- **Не пиши** «masterpiece, best quality» — в SDXL это мусорные слова, помогают
  только конкретные описания света, объектива и атмосферы.
- **Усиление слова** — возьми его в скобки: `(detailed skin texture:1.2)`.
  Ослабление — `(word:0.8)`. Не увлекайся: вес выше 1.3 ломает картинку.
- **CFG выше 7** на этой модели не поднимай — появляется «пережар» и ломаная
  анатомия. Для художественных стилей можно чуть выше, чем для фото.
- **Размер меньше 768 по меньшей стороне** для SDXL не бери — начнёт клонировать
  композицию. Портрет 832×1216, пейзаж 1216×832, квадрат 1024×1024.
- Один и тот же сюжет в разных стилях давай с **фиксированным Seed** — увидишь,
  как меняется именно стиль, а не композиция.
- Генерируй только взрослых персонажей.
