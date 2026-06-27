class_name OnboardingController
extends Node

signal finished

const GROUP := "onboarding_controller"
const LOBBY_TARGET_PLAYERS := OnboardingTutorialData.ROUND_COUNT

enum Step {
	NONE,
	RULES,
	LOBBY_ADD,
	LOBBY_NAME,
	LOBBY_SWAP,
	LOBBY_START,
	GAME_CHOICE,
	GAME_READY,
	GAME_PLAY,
	GAME_RESULT,
	COMPLETE,
}

@export var account: PDataAccount
@export var main_events: MainEvents
@export var pdata_controller: Node

var listener: EventListener = EventListener.new()
var _overlay: OnboardingOverlay
var _active := false
var _step := Step.NONE
var _menu: Node
var _game: Node
var _rules_window: RulesWindow
var _player_widget: PlayerSelectionWidget
var _start_button: BaseButton
var _menu_events: MenuEvents
var _game_manager: GameManager
var _game_events: GameEvents
var _start_round_button: BaseButton
var _overlay_paused := false
var _cached_roster: Array = []
var _tutorial_swap_applied := false
var _skipping_step := false


func _ready() -> void:
	add_to_group(GROUP)
	_overlay = OnboardingOverlay.new()
	add_child(_overlay)
	_overlay.skip_pressed.connect(_on_skip_pressed)
	_overlay.continue_pressed.connect(_on_overlay_continue_pressed)
	if main_events:
		listener.add(main_events.ev_start_game, _on_game_started)
		listener.add(main_events.ev_return_to_menu, _on_returned_to_menu)


func _exit_tree() -> void:
	listener.deinit()


func is_active() -> bool:
	return _active


static func get_controller(tree: SceneTree) -> OnboardingController:
	if tree == null:
		return null
	return tree.get_first_node_in_group(GROUP) as OnboardingController


static func is_onboarding_active(tree: SceneTree) -> bool:
	var node := get_controller(tree)
	return node != null and node.is_active()


func try_start_first_launch() -> void:
	if account == null:
		return
	if account.is_onboarding_completed() or account.was_onboarding_auto_started():
		return
	account.set_onboarding_auto_started(true)
	_save_account()
	start(false)


func start(replay: bool = true, skip_rules_step: bool = false) -> void:
	if _active:
		return
	_cache_roster()
	_tutorial_swap_applied = false
	_active = true
	_step = Step.NONE
	if account:
		account.set_players([])
	if _player_widget:
		_player_widget.reload_from_account()
	_enter_step(Step.LOBBY_ADD if skip_rules_step else Step.RULES)


func notify_lobby_name_step_completed() -> void:
	if not _active or _skipping_step:
		return
	if _step == Step.LOBBY_NAME:
		_advance()


func skip_current_step() -> void:
	if not _active:
		return
	_skipping_step = true
	match _step:
		Step.RULES:
			if _rules_window and _rules_window.visible:
				_rules_window.close()
			_advance()
		Step.LOBBY_ADD:
			_ensure_tutorial_players()
			_advance()
		Step.LOBBY_NAME:
			_advance()
		Step.LOBBY_SWAP:
			_apply_tutorial_swap()
			_advance()
		Step.LOBBY_START:
			_start_tutorial_battle()
			_advance()
		Step.GAME_CHOICE:
			_skip_player_choice()
		Step.GAME_READY:
			if _game_manager:
				_skip_game_ready_step()
		Step.GAME_PLAY:
			if _game_manager and _game_manager.fsm:
				var state_name := _game_manager.fsm.get_current_state_name()
				if state_name == FSMGameStates.EXPLOSION:
					_skip_explosion_step()
				else:
					_skip_scripted_round()
			else:
				_skip_scripted_round()
		Step.GAME_RESULT:
			_finish_tutorial_from_results()
		Step.COMPLETE:
			_finish_tutorial_from_results()
		_:
			_advance()
	_skipping_step = false


func pause_overlay() -> void:
	_overlay_paused = true
	_overlay.hide_overlay()


func resume_overlay() -> void:
	if not _active or not _overlay_paused:
		return
	_overlay_paused = false
	if _step != Step.RULES:
		_present_current_step()


func bind_menu(menu_context: Node) -> void:
	_menu = menu_context
	if menu_context == null:
		return
	_rules_window = menu_context.get("rules_window") as RulesWindow
	_player_widget = menu_context.get("player_selection_widget") as PlayerSelectionWidget
	_start_button = menu_context.get("start_button") as BaseButton
	_menu_events = menu_context.get("menu_events") as MenuEvents
	_bind_menu_listeners()
	if _active and _step == Step.NONE:
		call_deferred("_enter_step", Step.RULES)


func bind_game(game_context: Node) -> void:
	_game = game_context
	if game_context == null:
		return
	_game_manager = game_context.get("game_manager") as GameManager
	_game_events = game_context.get("game_events") as GameEvents
	var input_layer := game_context.get_node_or_null("UI/InputLayer")
	if input_layer:
		_start_round_button = input_layer.get("start_round_button") as BaseButton
	_bind_game_listeners()
	if _active and _game_manager:
		_game_manager.apply_tutorial_deck(OnboardingTutorialData.deck_entries())
	if _active:
		call_deferred("_resume_game_step")


func on_context_loaded(context: Node, scene_path: String, menu_path: String) -> void:
	if scene_path == menu_path:
		bind_menu(context)
	elif _active:
		bind_game(context)


func _bind_menu_listeners() -> void:
	if _menu_events == null:
		return
	if not _menu_events.ev_player_added.is_connected(_on_menu_players_changed):
		_menu_events.ev_player_added.connect(_on_menu_players_changed)
	if not _menu_events.ev_player_modified.is_connected(_on_menu_player_modified):
		_menu_events.ev_player_modified.connect(_on_menu_player_modified)
	if not _menu_events.ev_player_swapped.is_connected(_on_menu_player_swapped):
		_menu_events.ev_player_swapped.connect(_on_menu_player_swapped)
	if _rules_window:
		if not _rules_window.onboarding_continue_pressed.is_connected(_on_rules_continue):
			_rules_window.onboarding_continue_pressed.connect(_on_rules_continue)
		if not _rules_window.tutorial_requested.is_connected(_on_tutorial_from_rules):
			_rules_window.tutorial_requested.connect(_on_tutorial_from_rules)


func _bind_game_listeners() -> void:
	if _game_events == null:
		return
	if not _game_events.ev_game_state_changed.is_connected(_on_game_state_changed):
		_game_events.ev_game_state_changed.connect(_on_game_state_changed)
	if not _game_events.ev_touch_next_player.is_connected(_on_bomb_passed):
		_game_events.ev_touch_next_player.connect(_on_bomb_passed)


func _on_tutorial_from_rules() -> void:
	start(true, true)


func _on_rules_continue() -> void:
	if _step == Step.RULES:
		_advance()


func _on_skip_pressed() -> void:
	skip_current_step()


func _on_overlay_continue_pressed() -> void:
	if _step == Step.GAME_RESULT:
		_finish_tutorial_from_results()


func _on_menu_players_changed(_info: PlayerInfo = null) -> void:
	if _skipping_step:
		return
	if _step == Step.LOBBY_ADD and _lobby_player_count() >= LOBBY_TARGET_PLAYERS:
		_advance()


func _on_menu_player_modified(_info: PlayerInfo = null, _index: int = -1) -> void:
	if _skipping_step:
		return
	if _step == Step.LOBBY_NAME:
		_advance()


func _on_menu_player_swapped(_a: int = -1, _b: int = -1) -> void:
	if _skipping_step:
		return
	if _step == Step.LOBBY_SWAP:
		_tutorial_swap_applied = true
		_advance()


func _on_game_started(_data: Dictionary = {}) -> void:
	if _skipping_step:
		return
	if _step == Step.LOBBY_START:
		_advance()


func _on_returned_to_menu(_data: Dictionary = {}) -> void:
	_overlay.hide_overlay()
	if _rules_window and _rules_window.visible:
		_rules_window.close()
	if _active and _step == Step.GAME_RESULT:
		_complete()


func _on_game_state_changed(_from: String, to_state: String) -> void:
	if not _active:
		return
	match _step:
		Step.GAME_CHOICE:
			if to_state == FSMGameStates.READY_TO_START:
				_advance()
		Step.GAME_READY:
			if to_state == FSMGameStates.COUNTDOWN or to_state == FSMGameStates.PLAY:
				_advance()
		Step.GAME_PLAY:
			if to_state == FSMGameStates.PLAY:
				_present_play_step()
			elif to_state == FSMGameStates.READY_TO_START:
				_overlay.hide_overlay()
				_enter_step(Step.GAME_READY)
			elif to_state == FSMGameStates.EXPLOSION:
				_present_explosion_step()
			elif to_state == FSMGameStates.RESULT:
				_enter_step(Step.GAME_RESULT)
		_:
			if to_state == FSMGameStates.RESULT and _step > Step.LOBBY_START:
				_enter_step(Step.GAME_RESULT)


func _on_bomb_passed(_pos: Vector2 = Vector2.ZERO) -> void:
	pass


func _resume_game_step() -> void:
	if not _active:
		return
	if _step in [Step.LOBBY_START, Step.NONE]:
		_enter_step(Step.GAME_CHOICE)
	elif _step >= Step.GAME_CHOICE:
		_present_current_step()


func _advance() -> void:
	var next := _step + 1
	while next <= Step.COMPLETE and not _is_step_available(next):
		next += 1
	if next > Step.COMPLETE:
		_complete()
		return
	_enter_step(next)


func _is_step_available(step: Step) -> bool:
	match step:
		Step.LOBBY_NAME:
			return _lobby_player_count() >= LOBBY_TARGET_PLAYERS
		Step.LOBBY_SWAP:
			return _lobby_player_count() >= LOBBY_TARGET_PLAYERS
		Step.LOBBY_START:
			return _lobby_player_count() >= 2
	return true


func _enter_step(step: Step) -> void:
	_step = step
	match step:
		Step.RULES:
			_present_rules_step()
		_:
			_present_current_step()


func _present_rules_step() -> void:
	_overlay.hide_overlay()
	if _rules_window:
		_rules_window.open_for_onboarding()


func _present_current_step() -> void:
	if _overlay_paused:
		return
	match _step:
		Step.LOBBY_ADD:
			_present_add_players_step()
		Step.LOBBY_NAME:
			_show_lobby_step(
				LocaleService.text("ONBOARDING_NAME_TITLE"),
				LocaleService.text("ONBOARDING_NAME_BODY"),
				_first_player_icon()
			)
		Step.LOBBY_SWAP:
			_present_swap_step()
		Step.LOBBY_START:
			_show_lobby_step(
				LocaleService.text("ONBOARDING_START_TITLE"),
				LocaleService.text("ONBOARDING_START_BODY"),
				_start_button
			)
		Step.GAME_CHOICE:
			_show_game_step(
				LocaleService.text("ONBOARDING_CHOICE_TITLE"),
				LocaleService.text("ONBOARDING_CHOICE_BODY"),
				null
			)
		Step.GAME_READY:
			_show_game_step(
				LocaleService.text("ONBOARDING_READY_TITLE"),
				LocaleService.text("ONBOARDING_READY_BODY"),
				_start_round_button
			)
		Step.GAME_PLAY:
			_present_play_step()
		Step.GAME_RESULT:
			_present_result_step()
		_:
			pass


func _present_add_players_step() -> void:
	_overlay.set_pass_through(false)
	_overlay.set_continue_visible(false)
	_overlay.show_step(
		LocaleService.text("ONBOARDING_ADD_TITLE"),
		LocaleService.text("ONBOARDING_ADD_BODY"),
		true
	)
	_apply_add_player_spotlight()
	call_deferred("_apply_add_player_spotlight")


func _apply_add_player_spotlight() -> void:
	if _step != Step.LOBBY_ADD or _player_widget == null:
		return
	if _player_widget.add_player_button:
		_overlay.set_spotlight_control(_player_widget.add_player_button)


func _present_swap_step() -> void:
	var targets: Array = []
	if _player_widget:
		var icon_a := _player_widget.get_player_icon_at(OnboardingTutorialData.SWAP_INDEX_A)
		var icon_b := _player_widget.get_player_icon_at(OnboardingTutorialData.SWAP_INDEX_B)
		if icon_a:
			targets.append(icon_a)
		if icon_b:
			targets.append(icon_b)
	_overlay.set_pass_through(false)
	_overlay.set_continue_visible(false)
	_overlay.show_step(
		LocaleService.text("ONBOARDING_SWAP_TITLE"),
		LocaleService.text("ONBOARDING_SWAP_BODY"),
		true
	)
	if targets.is_empty():
		_overlay.clear_spotlight()
	else:
		_overlay.set_spotlight_controls(targets)


func _present_play_step() -> void:
	var round_idx := _tutorial_round_index()
	var body := OnboardingTutorialData.play_step_body_for_index(round_idx)
	if _game_manager and _game_manager.session.current_card:
		var card := _game_manager.session.current_card
		body = OnboardingTutorialData.play_step_body(card)
	_overlay.set_pass_through(true)
	_overlay.set_continue_visible(false)
	_overlay.show_step(LocaleService.text("ONBOARDING_PLAY_TITLE"), body, true)
	_overlay.clear_spotlight()


func _present_explosion_step() -> void:
	var round_idx := _tutorial_round_index()
	var explode_idx := OnboardingTutorialData.explode_player_index(round_idx)
	var body := OnboardingTutorialData.explosion_explanation(_tutorial_player_name(explode_idx))
	_overlay.set_pass_through(true)
	_overlay.set_continue_visible(false)
	_overlay.show_step(LocaleService.text("ONBOARDING_TIME_UP_TITLE"), body, true)
	_overlay.clear_spotlight()


func _present_result_step() -> void:
	_overlay.set_pass_through(true)
	_overlay.show_step(
		LocaleService.text("ONBOARDING_DONE_TITLE"),
		LocaleService.text("ONBOARDING_DONE_BODY"),
		true
	)
	_overlay.set_bottom_action(LocaleService.text("RESULT_TO_MENU"))
	_overlay.clear_spotlight()


func _show_lobby_step(title: String, body: String, focus: Control) -> void:
	_overlay.set_pass_through(false)
	_overlay.set_continue_visible(false)
	_overlay.show_step(title, body, true)
	if focus:
		_overlay.set_spotlight_control(focus)
	else:
		_overlay.clear_spotlight()


func _show_game_step(title: String, body: String, focus: Control) -> void:
	_overlay.set_pass_through(focus == null)
	_overlay.set_continue_visible(false)
	_overlay.show_step(title, body, true)
	if focus:
		_overlay.set_spotlight_control(focus)
	else:
		_overlay.clear_spotlight()


func _first_player_icon() -> Control:
	if _player_widget:
		return _player_widget.get_first_player_icon()
	return null


func _lobby_player_count() -> int:
	if account:
		return account.get_players().size()
	return 0


func _cache_roster() -> void:
	_cached_roster = account.get_players().duplicate(true) if account else []


func _restore_roster() -> void:
	if account:
		account.set_players(_cached_roster.duplicate(true))
	if _player_widget:
		_player_widget.reload_from_account()
	_cached_roster.clear()


func _ensure_tutorial_players() -> void:
	if not _player_widget or not account:
		return
	var infos := OnboardingTutorialData.player_infos(account)
	while _lobby_player_count() < LOBBY_TARGET_PLAYERS:
		var index := _lobby_player_count()
		if index >= infos.size():
			break
		_player_widget.add_player_direct(infos[index])


func _apply_tutorial_swap() -> void:
	if _tutorial_swap_applied or not _player_widget:
		return
	if _lobby_player_count() < 2:
		return
	_player_widget.swap_players_at_indices(
		OnboardingTutorialData.SWAP_INDEX_A,
		OnboardingTutorialData.SWAP_INDEX_B
	)
	_tutorial_swap_applied = true


func _start_tutorial_battle() -> void:
	if _lobby_player_count() < 2:
		_ensure_tutorial_players()
	if main_events:
		main_events.ev_start_game.emit({})


func _skip_player_choice() -> void:
	if _game_manager:
		_game_manager.force_finish_player_choice()


func _skip_game_ready_step() -> void:
	if _game_manager == null or _game_manager.fsm == null:
		return
	var state_name := _game_manager.fsm.get_current_state_name()
	if state_name == FSMGameStates.READY_TO_START:
		_game_manager.start_round()
	else:
		_skip_scripted_round()


func _skip_scripted_round() -> void:
	if _game_manager == null:
		return
	var round_idx := _tutorial_round_index()
	var explode_idx := OnboardingTutorialData.explode_player_index(round_idx)
	_game_manager.force_tutorial_explosion_at(explode_idx)


func _skip_explosion_step() -> void:
	if _game_manager:
		_game_manager.force_finish_explosion()


func _tutorial_round_index() -> int:
	if _game_manager == null:
		return 0
	var session := _game_manager.session
	if session.current_card != null:
		return OnboardingTutorialData.round_index_for_card(session.current_card)
	var played := session.match_cards_total - session.cards.size()
	return clampi(played, 0, OnboardingTutorialData.ROUND_COUNT - 1)


func _tutorial_player_name(player_index: int) -> String:
	if _game_manager == null:
		return ""
	var players := _game_manager.session.players
	if player_index < 0 or player_index >= players.size():
		return ""
	return players[player_index].info.name


func _return_to_menu_from_tutorial() -> void:
	if main_events:
		main_events.ev_return_to_menu.emit()


func _finish_tutorial_from_results() -> void:
	_complete()
	_return_to_menu_from_tutorial()


func _complete() -> void:
	_active = false
	_step = Step.NONE
	_overlay_paused = false
	_tutorial_swap_applied = false
	_overlay.hide_overlay()
	if _rules_window and _rules_window.visible:
		_rules_window.close()
	_restore_roster()
	if account:
		account.set_onboarding_completed(true)
	_save_account()
	finished.emit()


func _save_account() -> void:
	if pdata_controller and pdata_controller.has_method("save_account"):
		pdata_controller.save_account()
