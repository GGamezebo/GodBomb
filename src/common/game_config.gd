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
	"лом", "ка", "ев", "ма", "ли", "ук", "за", "вед", "ди", "ло", "аз", "ост",
	"от", "мат", "воз", "лю", "вик", "да", "хоз", "ран", "ат", "те", "ом",
	"ал", "ак", "ов", "изм", "вар", "га", "тор", "ус", "та", "ро", "ад",
	"фон", "лог", "ром", "он", "рез", "уб", "ни", "во", "вод", "акт", "по",
	"ча", "ор", "пан", "ле", "док", "не", "ке", "век", "мер", "мас", "бол",
	"суда", "ок", "па", "коп", "дел", "ил", "со", "на", "мо", "уз", "ар",
	"ки", "сон", "мет", "ик", "са", "ба", "то", "дик", "жу", "хо", "од",
	"инт", "ко", "ласт", "ун", "кол", "ан", "но", "пит", "ру", "ит", "аст",
	"ант", "лос", "му", "тел", "ист", "ам", "род", "ин", "ник", "кин", "ра",
	"рог", "ла", "ва", "ск", "ти", "ход", "лов", "тик", "метр", "ас",
])
@export var dev_players: Array[PlayerInfo] = []
