class_name SlimeColors
extends RefCounted

## 12 distinct player colors (Among Us–style palette), preset_id = array index.
const COLORS: Array[Color] = [
	Color("#D71E22"), # 0 red
	Color("#132ED1"), # 1 blue
	Color("#117F2D"), # 2 green
	Color("#ED54BA"), # 3 pink
	Color("#EF7D0D"), # 4 orange
	Color("#F5F557"), # 5 yellow
	Color("#3F474E"), # 6 black
	Color("#D6E0F0"), # 7 white
	Color("#6B2FBC"), # 8 purple
	Color("#71491E"), # 9 brown
	Color("#38FEDC"), # 10 cyan
	Color("#50EF39"), # 11 lime
]

const NAMES: Array[String] = [
	"Красный", "Синий", "Зелёный", "Розовый", "Оранжевый", "Жёлтый",
	"Чёрный", "Белый", "Фиолетовый", "Коричневый", "Бирюзовый", "Лайм",
]


static func get_color(preset_id: int) -> Color:
	if preset_id < 0 or preset_id >= COLORS.size():
		return Color.WHITE
	return COLORS[preset_id]


static func get_color_name(preset_id: int) -> String:
	if preset_id < 0 or preset_id >= NAMES.size():
		return ""
	return NAMES[preset_id]
