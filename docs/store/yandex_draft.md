# Черновик Яндекс Игр — Tic-Tac-Bada-Boom

Консоль: https://games.yandex.ru/console  
Доки: [заполнение черновика](https://yandex.ru/dev/games/doc/ru/console/add-new-game/draft), [требования](https://yandex.ru/dev/games/doc/ru/concepts/requirements)

Экспорт: preset **Yandex** (`custom_features=yandex`, HTML shell `yandex_template.html`) → `bin/yandex/` → Project → Tools → **Yandex Games: Package Web Export to Yandex ZIP**

---

## Шаг 1. Технические параметры

| Поле | Значение |
|------|----------|
| **Версия** | `1.0.0` |
| **Архив** | ZIP с `index.html` в корне, ≤100 МБ распакованным, без пробелов/кириллицы в путях |
| **Платформы** | Мобильные → **Android** (+ **iOS**, если есть Apple Team ID). Десктоп — только если сами проверили portrait в браузере |
| **Ориентация** | **Портретная** |

---

## Шаг 2. Метаданные

| Поле | Значение |
|------|----------|
| **Игра переведена на** | ru, en, sr, es, hi, de, fr, it *(как в `LocaleCatalog`)* |
| **Возрастной рейтинг** | **0+** (мультик-бомба, без жестокости; при сомнении — 6+) |
| **Категории** (≤2) | **Словесные**, **Казуальные** |
| **Теги** | для компании, локальный мультиплеер, вечеринка, слова, на одном телефоне, pass and play, hot potato, casual |
| **Ключевые слова** (≤100, нижний регистр) | бомба слова, вечеринка, словесная игра, party game, hot potato, локальный мультиплеер |

---

## Шаг 3. Дополнительные параметры

| Поле | Значение |
|------|----------|
| **Облачные сохранения** | **Выкл.** (настройки/игроки в `user://`, не `Player.setData`) |
| **Отсроченная публикация** | по желанию |
| **Комментарий разработчика** | см. ниже |

**Комментарий для модерации (вставить):**

```
Party-игра на одном устройстве: 2–12 игроков передают телефон по кругу.
SDK: LoadingAPI.ready, GameplayAPI start/stop, interstitial при выходе в меню после результата (cooldown), язык с i18n.lang.
Прогресс (имена, настройки) — локально в браузере, облачные сохранения SDK не используем.
Монетизация: interstitial РСЯ; покупок нет.
Ориентация только portrait 1080×1920.
```

---

## Шаг 4. Тексты — русский

### Название * (≤50)
```
Tic-Tac-Bada-Boom
```

### Описание для SEO (50–160)
```
Словесная вечеринка на одном телефоне: слог на циферблате, придумай слово и передай бомбу — не взорвись!
```
*(~108 символов)*

### Короткое описание (≤70)
```
Бомба-слова на одном телефоне. Передавай, придумывай, не взорвись.
```
*(~65 символов)*

### Об игре * (100–1000)
```
Садитесь кругом. Один телефон — бомба. На циферблате слог и условие: назовите слово вслух и тапните, чтобы передать соседу. Таймер скрыт — слишком долго думали, и бум: штрафное очко. Меньше штрафов — выше место. При ничьей включается овертайм на вылет.

От 2 до 12 игроков. В настройках — длительность партии и сложность. Режим «телефон в центре» поворачивает текст к текущему игроку — удобно для большой компании за столом.

Локальная вечеринка без аккаунтов и онлайна. Вибрация по желанию. Идеально для друзей, семьи и посиделок — нужна только одна трубка.
```

### Как играть * (100–1000)
```
1. Добавьте игроков в лобби (кнопка «+»), при желании смените имена и цвета слаймов.
2. Выберите длительность партии и нажмите старт.
3. На циферблате появится слог и подсказка: слог в начале, в конце или в любом месте слова.
4. Назовите подходящее слово вслух и коротким тапом передайте бомбу следующему.
5. Кому бомба взорвалась — получает штраф. Между раундами видно, сколько времени осталось.
6. В конце — таблица результатов. При равном минимуме штрафов — овертайм на вылет до одного победителя.

Аварийная кнопка — если ошиблись словом или тапом. Длинный свайп один раз за раунд возвращает бомбу предыдущему игроку.
```

---

## Шаг 4. Тексты — English

### Title *
```
Tic-Tac-Bada-Boom
```

### SEO (50–160)
```
Party word bomb on one phone: invent a word for the syllable, pass it fast — don’t blow up!
```
*(~95 chars)*

### Short description (≤70)
```
Party word bomb on one phone. Pass it, invent words, don’t explode.
```
*(~67 chars)*

### About the game *
```
Sit in a circle. One phone is the bomb. The dial shows a syllable and a rule — say a word out loud, tap to pass. The fuse is hidden. Too slow? Boom — a penalty. Fewest penalties win. Ties go to overtime knockout.

2–12 players. Adjust match length and difficulty. Optional “phone in the center” mode rotates the dial toward the current player so nobody spins the device.

Local multiplayer. No accounts, no online matchmaking. Optional vibration. Perfect for parties, family nights, and any table with one spare phone.
```

### How to play *
```
1. Add players in the lobby (+), edit names and slime colors if you like.
2. Set match length and start.
3. The dial shows a syllable and a hint: at the start, end, or anywhere in the word.
4. Say a fitting word out loud and tap once to pass the bomb to the next player.
5. Whoever holds the bomb when it explodes gets a penalty. Between rounds you see remaining time.
6. At the end, check the ranking. Equal lowest penalties trigger overtime knockout until one winner remains.

Use the emergency button for a wrong word or mis-tap. One long swipe per round returns the bomb to the previous player.
```

---

## Шаг 4. Остальные языки

В консоли включены AI-описания — можно автосгенерировать с EN.  
В игре уже есть UI: **sr, es, hi, de, fr, it** — в поле «Игра переведена на» указывайте только языки, которые реально проверили в debug-панели.

---

## Шаг 5–6. Визуал (сделать / снять)

| Материал | Спека | Статус в репо |
|----------|--------|----------------|
| **Иконка** * | PNG **512×512** | `assets/reference/store/yandex_icon_512.png` (не в билде) |
| **Maskable** | 512×512, важная графика в круге ~80% | опционально; `icon_adaptive_fg` + bg как референс |
| **Обложка** * | PNG **800×470** | `assets/reference/store/yandex_cover_800x470.png` (не в билде) |
| **Обложка витрины** | 1560×520 | опционально |
| **Скриншоты** * | portrait **9:16**, длинная сторона 1280–2560, ≥2 на мобильные | `assets/reference/store/screenshots/` — 19 шт. 1080×1920 (промо-моки + концепт); для модерации лучше 2–4 живых с телефона |
| Видео 9:16 / 16:9 | MP4 ≤28 с | опционально, но сильно помогает продвижению |

### Shot list (как в `listing.md`)

Готовые кадры (вне билда): `assets/reference/store/screenshots/`

| # | Файл | Контекст |
|---|------|----------|
| 00 | `00_title_splash.png` | Титул / обложка |
| 01 | `01_lobby_ready.png` | Лобби (концепт) |
| 02 | `02_battle_begin.png` | Бой: слог в начале (концепт) |
| 03 | `03_lobby_full.png` | Лобби, много игроков |
| 04 | `04_lobby_remove.png` | Удаление игрока |
| 05 | `05_countdown.png` | Жребий / countdown |
| 06 | `06_battle_anywhere.png` | Бой: слог в любом месте |
| 07 | `07_battle_end.png` | Бой: слог в конце |
| 08 | `08_pass_sparks.png` | Передача / искры |
| 09 | `09_explosion.png` | Взрыв |
| 10 | `10_emergency.png` | Авария |
| 11 | `11_overtime.png` | Овертайм |
| 12 | `12_results.png` | Рейтинг |
| 13 | `13_settings.png` | Настройки |
| 14 | `14_language.png` | Выбор языка |
| 15 | `15_rules.png` | Правила |
| 16 | `16_edit_player.png` | Редакт игрока |
| 17 | `17_onboarding.png` | Онбординг |
| 18 | `18_table_center.png` | Телефон в центре |

Для Яндекса в каталог достаточно 4–8 лучших; ≥2 мобильных обязательно.

---

## Чеклист перед «Отправить на модерацию»

- [ ] ZIP через плагин, `index.html` в корне  
- [ ] Export preset **Yandex**: feature `yandex`, shell `addons/yandex_games/templates/yandex_template.html`  
- [ ] Debug-панель: индикатор 文 зелёный **на старте** (I18N is used); `game_ready`; interstitial после матча  
- [ ] Очистить кеш → каждый язык из «Игра переведена на» (ru/en/sr/es/hi/de/fr/it) через SDK mocks — UI/правила/подсказки переключаются  
- [ ] Звук после первого жеста; пауза при уходе во вкладку  
- [ ] Portrait-заглушка SDK при landscape  
- [ ] Тексты RU+EN вставлены; категории и возрастной рейтинг  
- [ ] Иконка 512, обложка 800×470, ≥2 мобильных скриншота 9:16  
- [ ] Комментарий про локальные сейвы и рекламу  
