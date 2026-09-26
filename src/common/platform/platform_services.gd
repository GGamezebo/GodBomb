extends Node

## Cross-platform facade. The only platform entry point for game code.
## Picks one PlatformBackend by export feature: `yandex` → Yandex Games, `play` → Google Play,
## otherwise NullBackend (plain Web, editor, F6). Contexts / FSM never touch store SDKs directly.

const GAME_EVENTS_PATH := "res://src/common/game_events.tres"

var backend: PlatformBackend
var _game_events: GameEvents
var _listener: EventListener = EventListener.new()
var _gameplay_active: bool = false
var _match_finished: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	backend = _create_backend()
	backend.setup(self)
	if backend is NullBackend:
		return
	_game_events = load(GAME_EVENTS_PATH) as GameEvents
	if _game_events:
		_listener.add(_game_events.ev_game_state_changed, _on_game_state_changed)
	backend.boot.call_deferred()


func _exit_tree() -> void:
	_listener.deinit()


static func _create_backend() -> PlatformBackend:
	if OS.has_feature("yandex"):
		return YandexBackend.new()
	if OS.has_feature("play"):
		return GooglePlayBackend.new()
	return NullBackend.new()


func is_yandex() -> bool:
	return backend is YandexBackend


func is_google_play() -> bool:
	return backend is GooglePlayBackend


func _on_game_state_changed(_from: String, to_state: String) -> void:
	_set_gameplay_active(to_state == FSMGameStates.PLAY)
	if to_state == FSMGameStates.RESULT:
		_match_finished = true


func _set_gameplay_active(active: bool) -> void:
	if active == _gameplay_active:
		return
	_gameplay_active = active
	backend.set_gameplay_active(active)


func on_left_battle_context() -> void:
	_set_gameplay_active(false)


## Call before returning to menu. After a finished match the backend may show an ad / review.
func await_return_to_menu_gate() -> void:
	if not _match_finished:
		return
	_match_finished = false
	_set_gameplay_active(false)
	await backend.on_match_finished_return_to_menu()


func _on_history_back() -> void:
	# Smart TV / browser back — stop gameplay markup; exit confirm is product-specific.
	_set_gameplay_active(false)
	backend.on_history_back()
