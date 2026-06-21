class_name BattleEmergencyOverlay
extends CanvasLayer

const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"
const TABLE_CENTER := Vector2(540.0, 960.0)
const PREVIEW_SLIME_SIZE := Vector2(128.0, 128.0)
const EXPLANATION_TEXT := (
	"Если кто-то случайно или специально нарушил правила — "
	+ "например, назвал неверное слово или нажал на экран несколько раз, "
	+ "— здесь можно перевыбрать текущего персонажа, который должен переиграть свой ход."
)

@export var game_manager: GameManager
@export var game_events: GameEvents
@export var background_color: ColorRect
@export var layout_host: MenuBombLayout
@export var player_selection_widget: PlayerSelectionWidget
@export var explanation_banner: PanelContainer
@export var preview_column: Control
@export var preview_slime: TextureRect
@export var preview_name: Label
@export var continue_button: TextureButton

var listener: EventListener = EventListener.new()


func _ready() -> void:
	layer = 13
	visible = false
	if background_color:
		background_color.color = Color(0, 0, 0, 1)
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
		UiSounds.bind_button(continue_button, &"confirm")
	if player_selection_widget:
		player_selection_widget.emergency_selection_changed.connect(_on_selection_changed)
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
	if layout_host and not layout_host.layout_applied.is_connected(_layout_preview_on_table):
		layout_host.layout_applied.connect(_layout_preview_on_table)
	_setup_explanation_banner()


func _exit_tree() -> void:
	listener.deinit()


func configure(data: Dictionary) -> void:
	var manager: GameManager = data.get("game_manager")
	if manager:
		game_manager = manager


func _setup_explanation_banner() -> void:
	if not explanation_banner:
		return
	var text := explanation_banner.get_node_or_null("Margin/VBox/ExplanationText") as RichTextLabel
	if text:
		text.text = EXPLANATION_TEXT


func _on_game_state_changed(from_state: String, to_state: String) -> void:
	if to_state == FSMGameStates.EMERGENCY:
		open()
	elif from_state == FSMGameStates.EMERGENCY and to_state == FSMGameStates.PLAY:
		close_overlay()


func open() -> void:
	_ensure_game_manager()
	if not game_manager or not player_selection_widget:
		return
	var session := game_manager.session
	var current_index := session.current_player_index
	player_selection_widget.set_emergency_mode(true, current_index)
	player_selection_widget.load_from_session_players(session.players)
	_sync_preview(session.get_current_player().info)
	if continue_button is StartActionButton:
		(continue_button as StartActionButton).call_deferred("refresh_label_layout")
	call_deferred("_layout_preview_on_table")
	visible = true


func close_overlay() -> void:
	if player_selection_widget:
		player_selection_widget.set_emergency_mode(false)
	visible = false


func _on_selection_changed(_index: int, info: PlayerInfo) -> void:
	_sync_preview(info)
	call_deferred("_layout_preview_on_table")


func _layout_preview_on_table() -> void:
	if not preview_column or not preview_slime:
		return
	preview_slime.custom_minimum_size = PREVIEW_SLIME_SIZE
	preview_slime.size = PREVIEW_SLIME_SIZE
	preview_column.reset_size()
	var column_size := preview_column.get_combined_minimum_size()
	if column_size.x <= 0.0 or column_size.y <= 0.0:
		column_size = preview_column.size
	preview_column.size = column_size
	var slime_center_in_column := Vector2(column_size.x * 0.5, PREVIEW_SLIME_SIZE.y * 0.5)
	preview_column.position = TABLE_CENTER - slime_center_in_column


func _sync_preview(info: PlayerInfo) -> void:
	if preview_slime:
		preview_slime.texture = load(SLIME_PATH % info.preset_id)
	if preview_name:
		preview_name.text = info.name


func _on_continue_pressed() -> void:
	_ensure_game_manager()
	if not game_manager or not player_selection_widget:
		return
	game_manager.continue_emergency(player_selection_widget.get_emergency_selected_index())


func _ensure_game_manager() -> void:
	if game_manager:
		return
	var context := get_parent()
	if context:
		game_manager = context.get_node_or_null("GameManager") as GameManager
