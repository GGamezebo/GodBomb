extends Control

const DESIGN_SIZE := MenuBombLayout.DESIGN_SIZE
const ROUND_WORD_MARKER := &"RoundWord"
const FALLBACK_ROUND_WORD := Vector2(540, 928)
const TABLE_CENTER := GamePlayerStrip.TABLE_CENTER
const FALLBACK_HINT_MARKER := Vector2(528, 483)
const PASS_HINT_RECT := Rect2(48.0, 1415.0, 984.0, 96.0)

@export var game_manager: GameManager
@export var game_events: GameEvents
@export var result_panel: Control
@export var result_label: RichTextLabel

var listener: EventListener = EventListener.new()
var _player_strip: GamePlayerStrip
var _syllable_card: GameSyllableCard
var _hint_banner: TableHintBanner
var _time_progress_banner: GameTimeProgressBanner
var _action_hints: GameActionHints
var _battle_layer: Control
var _countdown_label: Label
var _explosion_overlay: GameExplosionOverlay
var _result_overlay: GameResultOverlay
var _current_state: String = ""
var _last_choice_player_index: int = -1
var _time_progress_token: int = 0


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	_build_ui()
	_connect_layout_reposition()
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_current_player_changed, _on_current_player_changed)
		listener.add(game_events.ev_countdown_tick_changed, _on_countdown_tick)
		listener.add(game_events.ev_card_changed, _on_card_changed)
		listener.add(game_events.ev_touch_next_player, _on_turn_passed)
	call_deferred("_sync_to_current_state")


func _exit_tree() -> void:
	listener.deinit()


func _find_bomb_layout() -> GameBombBackground:
	var ui := get_parent()
	if ui:
		return ui.get_node_or_null("BackgroundBomb") as GameBombBackground
	return null


func _get_design_root() -> Control:
	var layout := _find_bomb_layout()
	if layout and layout.scaled_content:
		return layout.scaled_content
	return self


func _connect_layout_reposition() -> void:
	var layout := _find_bomb_layout()
	if layout and not layout.layout_applied.is_connected(_reposition_battle_ui):
		layout.layout_applied.connect(_reposition_battle_ui)
	call_deferred("_reposition_battle_ui")


func _get_round_word_center() -> Vector2:
	var design_root := _get_design_root()
	return BombMarkerLayout.get_marker_position(design_root, ROUND_WORD_MARKER, FALLBACK_ROUND_WORD)


func _get_hint_marker_position() -> Vector2:
	var layout := _find_bomb_layout()
	if layout:
		return layout.get_hint_marker_design_position()
	return FALLBACK_HINT_MARKER


func _get_hint_bounds() -> Rect2:
	var layout := _find_bomb_layout()
	if layout:
		return TableHintBanner.visible_design_rect(layout.size)
	return Rect2(Vector2.ZERO, DESIGN_SIZE)


func _reposition_battle_ui() -> void:
	var design_root := _get_design_root()
	var word_center := _get_round_word_center()
	if _player_strip:
		GamePlayerStrip.place_on_dial(_player_strip, word_center, TABLE_CENTER)
	if _syllable_card:
		BombMarkerLayout.place_control_at_marker(
			_syllable_card, design_root, ROUND_WORD_MARKER, FALLBACK_ROUND_WORD
		)
	if _countdown_label:
		BombMarkerLayout.place_control_at_marker(
			_countdown_label, design_root, ROUND_WORD_MARKER, FALLBACK_ROUND_WORD
		)
	var hint_bounds := _get_hint_bounds()
	if _hint_banner:
		TableHintBanner.place_centered_at(_hint_banner, _get_hint_marker_position(), hint_bounds)
	if _time_progress_banner:
		_time_progress_banner.fit_layout(
			_get_hint_marker_position(), TableHintBanner.TABLE_HINT_WIDTH, hint_bounds
		)
	if _action_hints:
		_action_hints.position = PASS_HINT_RECT.position
		_action_hints.size = PASS_HINT_RECT.size
	if _explosion_overlay and _explosion_overlay.visible:
		_explosion_overlay.size = design_root.size
		_explosion_overlay.relayout()


func _build_ui() -> void:
	var design_root := _get_design_root()

	_battle_layer = Control.new()
	_battle_layer.name = "BattleLayer"
	_battle_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_battle_layer.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_battle_layer.size = DESIGN_SIZE
	_battle_layer.z_index = 2
	design_root.add_child(_battle_layer)

	_player_strip = GamePlayerStrip.new()
	_battle_layer.add_child(_player_strip)

	_syllable_card = GameSyllableCard.new()
	_battle_layer.add_child(_syllable_card)

	_hint_banner = TableHintBanner.new()
	_hint_banner.z_index = 5
	_battle_layer.add_child(_hint_banner)

	_time_progress_banner = GameTimeProgressBanner.new()
	_time_progress_banner.z_index = 6
	_battle_layer.add_child(_time_progress_banner)

	_action_hints = GameActionHints.new()
	_action_hints.game_events = game_events
	_action_hints.z_index = 4
	_battle_layer.add_child(_action_hints)

	_countdown_label = Label.new()
	_countdown_label.custom_minimum_size = Vector2(440, 440)
	_countdown_label.size = Vector2(440, 440)
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_countdown_label.add_theme_font_size_override("font_size", 140)
	_countdown_label.add_theme_color_override("font_color", Color.WHITE)
	_countdown_label.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.85))
	_countdown_label.add_theme_constant_override("outline_size", 10)
	_countdown_label.z_index = 3
	design_root.add_child(_countdown_label)

	_build_explosion_overlay(design_root)
	_build_result_overlay()


func _build_explosion_overlay(design_root: Control) -> void:
	_explosion_overlay = GameExplosionOverlay.new()
	design_root.add_child(_explosion_overlay)


func _build_result_overlay() -> void:
	_result_overlay = GameResultOverlay.new()
	var ui_layer := get_parent()
	if ui_layer:
		ui_layer.add_child.call_deferred(_result_overlay)
	else:
		add_child.call_deferred(_result_overlay)


func set_lobby_overlay_active(active: bool) -> void:
	if active:
		_hide_all()
	elif game_manager and game_manager.fsm:
		sync_from_session()


func sync_from_session() -> void:
	_sync_to_current_state()


func _hide_all() -> void:
	if _battle_layer:
		_battle_layer.visible = false
	if _hint_banner:
		_hint_banner.hide_message(false)
	if _time_progress_banner:
		_time_progress_banner.hide_progress(false)
	_cancel_time_progress_timer()
	if _action_hints:
		_action_hints.visible = false
	if _countdown_label:
		_countdown_label.visible = false
	if _explosion_overlay:
		_explosion_overlay.hide_overlay()
	if _result_overlay:
		_result_overlay.hide_overlay()
	if result_panel:
		result_panel.visible = false


func _sync_to_current_state() -> void:
	if not game_manager or not game_manager.fsm:
		_hide_all()
		return
	_on_game_state_changed("", game_manager.fsm.get_current_state_name())


func _on_game_state_changed(from_state: String, to_state: String) -> void:
	_current_state = to_state
	_hide_all()
	match to_state:
		FSMGameStates.PLAYER_CHOICE:
			_show_player_choice()
		FSMGameStates.READY_TO_START:
			_show_ready_to_start(from_state)
		FSMGameStates.COUNTDOWN:
			_show_countdown()
		FSMGameStates.PLAY:
			_show_play()
		FSMGameStates.EMERGENCY:
			_hide_all()
		FSMGameStates.EXPLOSION:
			_show_explosion()
		FSMGameStates.RESULT:
			_show_result()


func _on_current_player_changed(player: GamePlayer) -> void:
	if _player_strip:
		_player_strip.set_player(player)
		call_deferred("_reposition_battle_ui")
	if _current_state == FSMGameStates.PLAYER_CHOICE and player.index != _last_choice_player_index:
		_last_choice_player_index = player.index
		_player_strip.pulse_choice_tick()


func _on_countdown_tick(seconds_left: int) -> void:
	if _countdown_label:
		_countdown_label.text = str(seconds_left)
		_countdown_label.visible = true
		var tween := create_tween()
		tween.tween_property(_countdown_label, "scale", Vector2(1.12, 1.12), 0.08)
		tween.tween_property(_countdown_label, "scale", Vector2.ONE, 0.12)


func _on_card_changed(card: GameCard) -> void:
	if _syllable_card:
		_syllable_card.set_card(card)
	if _current_state == FSMGameStates.PLAY:
		_show_play_hint()


func _on_turn_passed(_touch_position: Vector2 = Vector2.ZERO) -> void:
	if _syllable_card:
		_syllable_card.pulse_next_turn()


func _show_hint(text: String) -> void:
	if _hint_banner:
		_hint_banner.show_message(text, false, true)


func _show_play_hint() -> void:
	if game_manager and game_manager.session.current_card:
		var condition := WordCondition.get_label(game_manager.session.current_card.condition)
		if not condition.is_empty():
			_show_hint(condition)
			return
	if _hint_banner:
		_hint_banner.hide_message(false)


func _sync_current_player() -> void:
	if game_manager:
		_on_current_player_changed(game_manager.session.get_current_player())


func _show_player_choice() -> void:
	_battle_layer.visible = true
	_player_strip.visible = true
	_last_choice_player_index = -1
	if _syllable_card:
		_syllable_card.visible = true
		_syllable_card.set_message("?")
	_show_hint("Кто ходит первым?")
	_sync_current_player()
	call_deferred("_reposition_battle_ui")


func _show_ready_to_start(from_state: String = "") -> void:
	_battle_layer.visible = true
	_player_strip.visible = true
	if _syllable_card:
		_syllable_card.visible = true
		_syllable_card.set_message("Готовы?")
	_sync_current_player()
	call_deferred("_reposition_battle_ui")
	if from_state == FSMGameStates.EXPLOSION and _should_show_time_progress():
		_show_between_rounds_progress()
	else:
		_show_hint("Нажми «Начать раунд»")


func _should_show_time_progress() -> bool:
	if game_manager == null or game_manager.session == null:
		return false
	return game_manager.session.match_cards_total > 1


func _show_between_rounds_progress() -> void:
	if _hint_banner:
		_hint_banner.hide_message(false)
	if _time_progress_banner == null:
		_show_hint("Нажми «Начать раунд»")
		return
	var ratio := game_manager.session.get_match_remaining_ratio()
	_time_progress_banner.show_progress(ratio)
	_time_progress_token += 1
	var token := _time_progress_token
	get_tree().create_timer(GameTimeProgressBanner.SHOW_DURATION).timeout.connect(
		func() -> void:
			if token == _time_progress_token:
				_on_time_progress_finished(),
		CONNECT_ONE_SHOT
	)


func _on_time_progress_finished() -> void:
	if _time_progress_banner:
		_time_progress_banner.hide_progress()
	if _current_state == FSMGameStates.READY_TO_START:
		_show_hint("Нажми «Начать раунд»")


func _cancel_time_progress_timer() -> void:
	_time_progress_token += 1


func _show_countdown() -> void:
	_battle_layer.visible = true
	_player_strip.visible = true
	if _syllable_card:
		_syllable_card.visible = false
	if _countdown_label:
		_countdown_label.visible = true
	_sync_current_player()
	call_deferred("_reposition_battle_ui")


func _show_play() -> void:
	_battle_layer.visible = true
	_player_strip.visible = true
	if _action_hints:
		_action_hints.visible = true
	if _syllable_card:
		_syllable_card.visible = true
	_sync_current_player()
	call_deferred("_reposition_battle_ui")
	if game_manager and game_manager.session.current_card:
		_on_card_changed(game_manager.session.current_card)
	else:
		_show_play_hint()


func _show_explosion() -> void:
	if not _explosion_overlay or not game_manager:
		return
	var player := game_manager.session.get_current_player()
	_explosion_overlay.show_for_player(player)


func _show_result() -> void:
	if not _result_overlay or not game_manager:
		return
	var sorted := game_manager.session.get_sorted_results()
	_result_overlay.show_results(sorted)
