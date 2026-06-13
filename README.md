# GodBomb

Порт party-игры «Бомба» с Unity на **Godot 4.6.3 / GDScript**.  
Архитектура повторяет [quizmatik](../quizmatik): контексты, event-ресурсы, FSM, `EventListener`, без autoload.

## Запуск

1. Открыть проект в Godot 4.6.3
2. Главная сцена: `main.tscn`
3. F6 — любая сцена должна стартовать без падений (с дефолтными `@export`)

## Структура

| Путь | Назначение |
|------|------------|
| `src/contexts/main_context/` | `MainContext`, сохранение аккаунта |
| `src/contexts/menu_context/` | Лобби, игроки, длительность партии |
| `src/contexts/game_context/` | Матч: FSM, бомба, HUD, звук |
| `src/common/` | `GameConfig`, события, модели игрока/карты |
| `core/lib/` | FSM, `EventListener`, `ResourceUtils` |
| `assets/` | Спрайты, текстуры, аудио из Unity |

## Этапы порта

### Этап 1 — Фундамент ✅
- `.gitignore`, `.cursorignore`, `.cursor/rules/` (как в quizmatik)
- `project.godot`, `core/lib/`, event-ресурсы, `IContext`, `MainContext`
- Копирование ассетов из Unity

### Этап 2 — Меню ✅ (базовая версия)
- `MenuContext`: список игроков, пресеты слаймов, слайдер времени
- `PDataAccount` → `user://account.tres`
- Старт игры через `MainEvents.ev_start_game`

### Этап 3 — Игровой контекст ✅ (ядро)
- FSM: `player_choice` → `ready_to_start` → `countdown` → `play` → `explosion` → `result`
- `GameSession`: колода карт, таймер бомбы, очки
- HUD, ввод (тап / свайп назад), возврат в меню с экрана результатов
- Базовый звук (countdown, play, alert ticks, explosion)

### Этап 4 — Полировка (TODO)
- [ ] Круглый стол с drag-and-drop как в Unity (`PlayerSelectionWidget`)
- [ ] Анимации бомбы и фона
- [ ] VFX взрыва, haptics (мобильная вибрация)
- [ ] Полный визуал меню (фоны, кнопки из `assets/sprites/`)
- [ ] Локализация через CSV/TranslationServer

### Этап 5 — Экспорт (TODO)
- [ ] Android / iOS пресеты
- [ ] Проверка portrait 1080×1920 на устройствах

## Отличия от Unity-версии

- Один `GameContext` вместо отдельной сцены `Game.unity` + `GlobalContext`
- Состояния матча — FSM quizmatik, а не switch в `Update()`
- Сохранение — Godot `Resource` вместо JSON + `JsonUtility`
- UI лобби упрощён (список вместо кругового виджета) — доработка в этапе 4

## Язык

- Код и комментарии — английский
- UI — русский
