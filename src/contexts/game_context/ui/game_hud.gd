extends Control

@export var game_manager: GameManager
@export var game_events: GameEvents
@export var info_label: RichTextLabel
@export var player_name_label: Label
@export var countdown_label: Label
@export var result_panel: Control
@export var result_label: RichTextLabel

var listener: EventListener = EventListener.new()


func _ready() -> void:
	listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
	listener.add(game_events.ev_current_player_changed, _on_current_player_changed)
	listener.add(game_events.ev_countdown_tick_changed, _on_countdown_tick)
	listener.add(game_events.ev_card_changed, _on_card_changed)
	_hide_all()


func _exit_tree() -> void:
	listener.deinit()


func _hide_all() -> void:
	if info_label:
		info_label.visible = false
	if player_name_label:
		player_name_label.visible = false
	if countdown_label:
		countdown_label.visible = false
	if result_panel:
		result_panel.visible = false


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	_hide_all()
	match to_state:
		FSMGameStates.READY_TO_START:
			_show_ready_to_start()
		FSMGameStates.COUNTDOWN:
			if countdown_label:
				countdown_label.visible = true
		FSMGameStates.PLAY:
			_show_play()
		FSMGameStates.EXPLOSION:
			_show_explosion()
		FSMGameStates.RESULT:
			_show_result()
		FSMGameStates.PLAYER_CHOICE:
			if player_name_label:
				player_name_label.visible = true


func _on_current_player_changed(player: GamePlayer) -> void:
	if player_name_label:
		player_name_label.text = player.info.name
		player_name_label.visible = true


func _on_countdown_tick(seconds_left: int) -> void:
	if countdown_label:
		countdown_label.text = str(seconds_left)
		countdown_label.visible = true


func _on_card_changed(card: GameCard) -> void:
	if info_label and game_manager:
		var place := WordCondition.get_label(card.condition)
		info_label.text = "[center][font_size=60](%s)[/font_size]\n[font_size=90]%s[/font_size][/center]" % [
			place, card.word
		]


func _show_ready_to_start() -> void:
	if info_label:
		info_label.text = "[center]Нажми, чтобы начать следующий раунд![/center]"
		info_label.visible = true


func _show_play() -> void:
	if info_label:
		info_label.visible = true
	if player_name_label:
		player_name_label.visible = true
	if game_manager and game_manager.session.current_card:
		_on_card_changed(game_manager.session.current_card)


func _show_explosion() -> void:
	if info_label and game_manager:
		var player := game_manager.session.get_current_player()
		info_label.text = "[center][font_size=75]Игрок: %s[/font_size]\n[font_size=39]Вас подорвало![/font_size][/center]" % player.info.name
		info_label.visible = true


func _show_result() -> void:
	if not result_panel or not result_label or not game_manager:
		return
	result_panel.visible = true
	var lines: PackedStringArray = PackedStringArray()
	var sorted := game_manager.session.get_sorted_results()
	for i in sorted.size():
		var player: GamePlayer = sorted[i]
		lines.append("%d. %s — %d" % [i + 1, player.info.name, player.score])
	result_label.text = "[center][font_size=48]Результаты[/font_size]\n[font_size=36]%s[/font_size]\n\nНажми, чтобы вернуться в меню[/center]" % "\n".join(lines)
