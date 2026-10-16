---
description: Визуальный референс GodBomb — industrial bomb UI (концепт)
paths:
  - "assets/**"
  - "src/features/**"
  - "src/contexts/**/ui/**"
  - "src/ui/**"
  - "tools/generate_app_icons.ps1"
---

# Visual reference

**Концепт (ориентир при UI/арт-правках, только dev — не в билде). Открывай PNG через Read, чтобы посмотреть:**
- `assets/reference/concept/lobby-ready.png` — лобби, «Готовы?», баннер подсказки
- `assets/reference/concept/battle-dial.png` — бой, циферблат, слоты игроков

Папка `assets/reference/` — `.gdignore` + `exclude_filter` в `export_presets.cfg`; не ссылаться из `res://` в рантайме.

## Стиль концепта
- Корпус: тёмный brushed metal, царапины, потёртость, винты, тех-декали (serial, hazard)
- Ремни (кожа + chainmail), толстые провода R/Y/B по краям
- UI встроен в устройство: глубина, не плоский Material
- Фон сцены: тёмно-красный
- Циферблат: тёмное стекло, искры; shader — `bomb_dial_glass.gdshader`
- Баннеры подсказок: тёмная плашка, медно-оранжевая рамка — `TableHintBanner`
- Кнопки: металл + медная окантовка — `start_active.svg`, `icon_*.svg`, `BombTopBarButton` (мягкое медное свечение; Emergency `alert_glow` — объёмный SVG + мягкая аура/редкий блик)
- Иконки: одна `assets/icon.png` везде. Android: **Gradle build** (`gradle_build/use_gradle_build=true`, шаблон `android/build/`) — иначе `splash_screen/background_color` не попадает в APK и вспышка белого на старте. Источник иконки — квадратный мастер `assets/reference/store/app_icon_1024.png` (телефон-бомба с динамитом на красном градиенте; исходный вертикальный арт и варианты — `assets/reference/store/icon_candidates/`). Все `assets/icon*.png`, `boot_splash.png` (арт в безопасном круге Android 12) и иконки сторов `google_play_icon_512.png` / `yandex_icon_512.png` генерирует `python tools/generate_app_icons_from_art.py`, затем реимпорт (редактор или `--headless --import`). Старый `tools/generate_app_icons.ps1` (процедурная бомба) устарел — не запускать, он перезапишет иконки.
- Модальные CTA: `ModalButton` / `Button` в `src/ui/god_bomb_ui.theme.tres` — как СТАРТ

## Пока НЕ в стиле концепта (не копировать как эталон)
- Лампочки-индикаторы (`BombLamps`)

При полировке кнопок/ламп — сверяться с металлом/проводами/рамками концепта, не с текущими placeholder-кнопками на скринах.
