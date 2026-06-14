extends Control

const DESIGN_SIZE := MenuBombLayout.DESIGN_SIZE
const PLAYER_NAME_MARKER := &"PlayerName"
const ROUND_WORD_MARKER := &"RoundWord"
const FALLBACK_PLAYER_NAME := Vector2(528, 483)
const FALLBACK_ROUND_WORD := Vector2(540, 928)

@export var game_manager: GameManager
@export var game_events: GameEvents
@export var result_panel: Control
@export var result_label: RichTextLabel

var listener: EventListener = EventListener.new()
var _vignette: GameBattleVignette
var _player_strip: GamePlayerStrip
var _syllable_card: GameSyllableCard
var _action_hints: GameActionHints
var _battle_layer: Control
var _countdown_label: Label
var _explosion_panel: PanelContainer
var _explosion_title: Label
var _explosion_subtitle: Label
var _current_state: String = ""
var _last_choice_player_index: int = -1


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
	_sync_to_current_state()


func _exit_tree() -> void:
	listener.deinit()


func _find_bomb_layout() -> MenuBombLayout:
	var ui := get_parent()
	if ui:
		return ui.get_node_or_null("BackgroundBomb") as MenuBombLayout
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


func _get_player_name_anchor() -> Vector2:
	var layout := _find_bomb_layout()
	if layout:
		return layout.get_hint_marker_design_position()
	var design_root := _get_design_root()
	return BombMarkerLayout.get_marker_position(design_root, PLAYER_NAME_MARKER, FALLBACK_PLAYER_NAME)


func _reposition_battle_ui() -> void:
	var design_root := _get_design_root()
	if _player_strip:
		var anchor := _get_player_name_anchor()
		var size := _player_strip.size
		if size.x <= 0.0 or size.y <= 0.0:
			size = _player_strip.custom_minimum_size
		_player_strip.position = anchor - size * 0.5
	if _syllable_card:
		BombMarkerLayout.place_control_at_marker(
			_syllable_card, design_root, ROUND_WORD_MARKER, FALLBACK_ROUND_WORD
		)
	if _countdown_label:
		BombMarkerLayout.place_control_at_marker(
			_countdown_label, design_root, ROUND_WORD_MARKER, FALLBACK_ROUND_WORD
		)


func _build_ui() -> void:
	var design_root := _get_design_root()

	_vignette = GameBattleVignette.new()
	_vignette.game_events = game_events
	_vignette.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_vignette.size = DESIGN_SIZE
	_vignette.z_index = 1
	design_root.add_child(_vignette)

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

	_action_hints = GameActionHints.new()
	_action_hints.game_events = game_events
	_action_hints.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_action_hints.offset_left = 80.0
	_action_hints.offset_top = 1120.0
	_action_hints.offset_right = 1000.0
	_action_hints.offset_bottom = 1240.0
	_battle_layer.add_child(_action_hints)

	_countdown_label = Label.new()
	_countdown_label.custom_minimum_size = Vector2(440, 440)
	_countdown_label.size = Vector2(440, 440)
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_countdown_label.add_theme_font_size_override("font_size", 140)
	_countdown_label.add_theme_color_override("font_color", TurnOrderArrowsLayer.ACCENT)
	_countdown_label.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.85))
	_countdown_label.add_theme_constant_override("outline_size", 10)
	_countdown_label.z_index = 3
	design_root.add_child(_countdown_label)

	_build_explosion_overlay(design_root)


func _build_explosion_overlay(design_root: Control) -> void:
	_explosion_panel = PanelContainer.new()
	_explosion_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_explosion_panel.size = DESIGN_SIZE
	_explosion_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.03, 0.02, 0.62)
	_explosion_panel.add_theme_stylebox_override("panel", style)
	_explosion_panel.z_index = 4
	design_root.add_child(_explosion_panel)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_explosion_panel.add_child(center)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	center.add_child(col)

	_explosion_title = Label.new()
	_explosion_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_explosion_title.add_theme_font_size_override("font_size", 72)
	_explosion_title.add_theme_color_override("font_color", Color(1, 0.94, 0.88, 1))
	_explosion_title.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.02, 0.9))
	_explosion_title.add_theme_constant_override("outline_size", 6)
	col.add_child(_explosion_title)

	_explosion_subtitle = Label.new()
	_explosion_subtitle.text = "Вас подорвало!"
	_explosion_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_explosion_subtitle.add_theme_font_size_override("font_size", 40)
	_explosion_subtitle.add_theme_color_override("font_color", TurnOrderArrowsLayer.ACCENT.lightened(0.15))
	col.add_child(_explosion_subtitle)


func _hide_all() -> void:
	if _battle_layer:
		_battle_layer.visible = false
	if _countdown_label:
		_countdown_label.visible = false
	if _explosion_panel:
		_explosion_panel.visible = false
	if result_panel:
		result_panel.visible = false


func _sync_to_current_state() -> void:
	if not game_manager or not game_manager.fsm:
		_hide_all()
		return
	_on_game_state_changed("", game_manager.fsm.get_current_state_name())


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	_current_state = to_state
	_hide_all()
	match to_state:
		FSMGameStates.PLAYER_CHOICE:
			_show_player_choice()
		FSMGameStates.READY_TO_START:
			_show_ready_to_start()
		FSMGameStates.COUNTDOWN:
			if _countdown_label:
				_countdown_label.visible = true
		FSMGameStates.PLAY:
			_show_play()
		FSMGameStates.EXPLOSION:
			_show_explosion()
		FSMGameStates.RESULT:
			_show_result()


func _on_current_player_changed(player: GamePlayer) -> void:
	if _player_strip:
		_player_strip.set_player(player)
	if _current_state == FSMGameStates.PLAYER_CHOICE and player.index != _last_choice_player_index:
		_last_choice_player_index = player.index
		_player_strip.pulse_choice_tick()
	_sync_prev_hint()


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


func _on_turn_passed() -> void:
	if _syllable_card:
		_syllable_card.pulse_next_turn()


func _sync_prev_hint() -> void:
	if not _action_hints or not game_manager:
		return
	_action_hints.set_prev_blocked(game_manager.session.is_blocked_prev_player)


func _show_player_choice() -> void:
	_battle_layer.visible = true
	_player_strip.visible = true
	_action_hints.visible = false
	_last_choice_player_index = -1
	if _player_strip:
		_player_strip.set_turn_caption("Выбираем первого...")
	if _syllable_card:
		_syllable_card.set_message("?", "Кто ходит первым?")
	if game_manager:
		_on_current_player_changed(game_manager.session.get_current_player())


func _show_ready_to_start() -> void:
	_battle_layer.visible = true
	_player_strip.visible = true
	_action_hints.visible = false
	if _player_strip:
		_player_strip.set_turn_caption("Первым ходит")
	if _syllable_card:
		_syllable_card.set_message("Готовы?", "Нажми «Начать раунд»")
	if game_manager:
		_on_current_player_changed(game_manager.session.get_current_player())


func _show_play() -> void:
	_battle_layer.visible = true
	_player_strip.visible = true
	_action_hints.visible = true
	if _player_strip:
		_player_strip.set_turn_caption("Сейчас ходит")
	_sync_prev_hint()
	if game_manager:
		_on_current_player_changed(game_manager.session.get_current_player())
		if game_manager.session.current_card:
			_on_card_changed(game_manager.session.current_card)


func _show_explosion() -> void:
	if not _explosion_panel or not game_manager:
		return
	var player := game_manager.session.get_current_player()
	_explosion_title.text = player.info.name
	_explosion_panel.visible = true


func _show_result() -> void:
	if not result_panel or not result_label or not game_manager:
		return
	result_panel.visible = true
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.05, 0.88)
	result_panel.add_theme_stylebox_override("panel", style)
	var lines: PackedStringArray = PackedStringArray()
	var sorted := game_manager.session.get_sorted_results()
	for i in sorted.size():
		var player: GamePlayer = sorted[i]
		lines.append("%d. %s — %d" % [i + 1, player.info.name, player.score])
	result_label.text = "[center][font_size=52][color=#F5E6D3]Результаты[/color][/font_size]\n[font_size=38][color=#FFF8F0]%s[/color][/font_size]\n\n[font_size=28][color=#E8A04A]Нажми, чтобы вернуться в меню[/color][/font_size][/center]" % "\n".join(lines)
