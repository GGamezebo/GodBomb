# GodBomb

Порт party-игры «Бомба» с Unity на **Godot 4.6.3 / GDScript**.  
Архитектура повторяет quizmatik: контексты, event-ресурсы, FSM, `EventListener`, без autoload.

## Запуск

1. Открыть проект в Godot 4.6.3
2. Главная сцена: `main.tscn`
3. F6 — любая сцена должна стартовать без падений (с дефолтными `@export`)

## Структура

| Путь | Назначение |
|------|------------|
| `src/contexts/main_context/` | `MainContext`, сохранение аккаунта |
| `src/contexts/menu_context/` | Лобби, настройки времени партии |
| `src/contexts/game_context/` | Матч: FSM, HUD, звук |
| `src/features/player_selection/` | Круглый стол, drag-and-drop, окно редактирования |
| `src/features/bomb/` | Анимации бомбы |
| `src/features/background/` | Фон (камень/лава) |
| `src/features/explosion/` | VFX взрыва |
| `core/systems/haptics/` | Вибрация на mobile |
| `core/lib/` | FSM, `EventListener`, `ResourceUtils` |
| `assets/` | Спрайты, текстуры, аудио из Unity |

## Этапы порта

### Этапы 1–5 ✅
Фундамент, меню, игровой FSM, ассеты, сохранение аккаунта.

### Этап 6 — Полировка ✅
- Круглый `PlayerSelectionWidget`: drag swap, удаление на кнопку, hold 2s → редактирование
- `EditPlayerWindow` с выбором пресета слайма
- `PlayerPresetStorage` — блокировка занятых цветов
- Визуал меню: `Background_Menu`, текстуры кнопки старта
- `BombVisual` — анимации ready / comes / alert / boom
- `GameBackground` — слои stone/lava + реакция на alert/explosion
- `ExplosionEffect` — CPUParticles2D
- `HapticsManager` — `Input.vibrate_handheld` на play/alert/explosion

### Этап 7 — Экспорт (TODO)
- [ ] Android / iOS пресеты
- [ ] Проверка portrait 1080×1920 на устройствах
- [ ] Локализация через CSV (опционально)

## Управление в матче

- **Тап** — передать бомбу следующему игроку
- **Длинный свайп** — вернуть предыдущему (1 раз за раунд)
- **Экран результатов** — тап для возврата в меню

## Лобби

- **Кнопка «+»** — добавить игрока
- **Перетаскивание** на другого игрока — поменять местами
- **Перетаскивание на «+»** (в режиме удаления) — убрать игрока
- **Удержание 2 сек** — редактировать имя и слайм

## Язык

- Код и комментарии — английский
- UI — русский
