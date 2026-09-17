class_name GameConfig
extends Resource

@export var max_players: int = 12
@export var min_players: int = 2
@export var player_choice_time: float = 5.0
@export var countdown_time: float = 5.0
@export var min_bomb_alive_time: float = 10.0
@export var max_bomb_alive_time: float = 60.0
@export var bonus_bomb_alive_time: float = 5.0
@export var alert_bomb_time: float = 5.0
@export var explosion_countdown_time: float = 5.0
@export var drag_prev_player_threshold: float = 650.0
@export var cards: PackedStringArray = PackedStringArray([
	"ка", "ма", "ли", "за", "ди", "ло", "от", "да", "те", "ал", "ак", "ов",
	"га", "та", "ро", "ад", "он", "ни", "во", "по", "ле", "не", "па", "ил",
	"со", "на", "мо", "ар", "ки", "са", "ба", "то", "хо", "од", "ко", "ан",
	"но", "ру", "ам", "ин", "ра", "ла", "ва", "ти", "ас", "му", "ус", "ун",
	"ит", "ок", "ор", "ев", "ук", "ча", "ке", "ик",
	"мат", "воз", "лю", "вик", "ран", "ат", "ом", "вар", "тор", "фон", "лог", "ром",
	"рез", "уб", "вод", "акт", "пан", "док", "век", "мер", "мас", "бол", "коп", "дел",
	"сон", "мет", "дик", "жу", "кол", "пит", "аст", "ант", "лос", "тел", "ист", "род",
	"ник", "кин", "рог", "ск", "ход", "лов", "тик", "ост", "аз", "хоз", "вед", "лом",
	"уз",
])
