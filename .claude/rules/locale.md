---
description: Локализация — LocaleService, строки, колоды слогов
paths:
  - "src/common/locale/**"
  - "src/common/word_condition.gd"
  - "src/features/menu/language_flag_picker.*"
  - "src/features/menu/rules_window.*"
---

# Локализация

**Локали:** `LocaleCatalog.ORDER` = ru, en, sr, es, hi, de, fr, it. `normalize()`: `en-US`/`ru_RU` → primary subtag; неподдерживаемые: CIS (`be`, `kk`, `uk`, `uz`) → ru, остальное → en. Флаги `assets/ui/flags/flag_{code}.svg`, `NATIVE_NAMES`.

**API:** autoload `LocaleService` — `text(key)`, `textf(key, args)`, `get_locale()`, `set_locale(code, persist)` (пишет в `PDataAccount`), сигнал `locale_changed`. Инициализация `init_from_account()` (дефолт — системная локаль). Платформенный язык (Yandex) приходит только через `PlatformServices`.

**Строки:** `LocaleStrings` — таблицы `_RU` / `_EN` + rules footer (`RULES_TEXT_*`, само содержание правил — ключи `RULES_<CARD>_TITLE/BODY` + подписи картинок `RULES_ILL_*`, слова-примеры с `[слогом]` в скобках); `LocaleStringsLocales` — sr/es/hi/de/fr/it (`ui_table()`), fallback → EN → сам ключ. Новый ключ UI — добавлять **минимум в RU и EN**, по возможности во все локали. Ключи `LANG_*` → native name.

**Дефолтные имена игроков:** `_SLIME_RU/_EN` + `SLIME_*` — предметы цвета слайма (Помидор, Аватар, … Киви), индекс = `preset_id`. Старые имена-цвета лежат в `_LEGACY_SLIME_NAMES` — `default_slime_index()` их распознаёт, и `retranslate_default_names()` меняет их на текущие имена.

**Колоды:** `GameDecks` (`game_decks.gd`) · `*_RESTRICT` = позиции, где слово не придумать. Standard locales `B` (не в начале) · `E` (не в конце) · `BE` (только «в любом месте»); FR/IT exclusion-условия мягче (`LocaleCatalog.uses_exclusion_conditions`) → свои флаги `S` (бывает только в начале) · `F` (только в конце), `ITALIAN_RESTRICT` пуст. Сложность easy/medium/hard влияет на длину слога / жёсткость условия. Сербский (deck + tutorial + `NATIVE_NAMES`) — **latinica**.
