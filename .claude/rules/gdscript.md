---
description: GDScript стиль
paths:
  - "**/*.gd"
---

# GDScript

EN comments · typed `@export` · `class_name` в отдельном файле · минимальный дифф · отступы табами (как в существующем коде).

**Имена:** PascalCase классы · `ev_snake` сигналы · `_private` методы · snake `@export`.

**EventListener:** `listener.add` в `_ready`, `listener.deinit()` в `_exit_tree`.

**Пути:** механика → `src/features/` · экран → `src/contexts/` · общее → `src/common/` · утилиты → `core/lib/`.

**Контекст для агента:** после изменений механик/UI/audio — **сразу** обнови нужный `.claude/rules/*.md` (кратко, факты+пути, без дублирования). lobby · battle · audio · arch · locale · yandex.

**Избегать:** autoloads для связи экранов · прямых ссылок между контекстами · хардкода сцен · хардкода UI-строк (→ `LocaleService.text`).
