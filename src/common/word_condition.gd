class_name WordCondition
extends RefCounted

enum Type {
	BEGIN,
	ANYWHERE,
	END,
}

const LABELS: Dictionary = {
	Type.BEGIN: "В начале слова",
	Type.ANYWHERE: "Где угодно",
	Type.END: "В конце слова",
}

const MESSAGE_FONT_MAX := 112
const MESSAGE_FONT_MIN := 56
const PATTERN_HI_FONT_MAX := 140
const PATTERN_HI_FONT_MIN := 72
const PATTERN_DIM_RATIO := 0.72


static func random() -> int:
	var conditions: Array[int] = [Type.BEGIN, Type.ANYWHERE, Type.END]
	return conditions[randi() % conditions.size()]


static func get_label(condition: int) -> String:
	return LABELS.get(condition, "")


static func get_pattern_hint(syllable: String, condition: int) -> String:
	match condition:
		Type.BEGIN:
			return "[%s]___" % syllable
		Type.END:
			return "___[%s]" % syllable
		Type.ANYWHERE:
			return "_%s_" % syllable
		_:
			return syllable


static func get_pattern_display_bbcode(syllable: String, condition: int, max_width: float = 400.0) -> String:
	var hi_size := PATTERN_HI_FONT_MAX
	var dim_size := int(float(hi_size) * PATTERN_DIM_RATIO)
	while hi_size >= PATTERN_HI_FONT_MIN:
		dim_size = maxi(int(float(hi_size) * PATTERN_DIM_RATIO), 56)
		if _measure_pattern_width(syllable, condition, hi_size, dim_size) <= max_width:
			return _build_pattern_bbcode(syllable, condition, hi_size, dim_size)
		hi_size -= 4
	return _build_pattern_bbcode(syllable, condition, PATTERN_HI_FONT_MIN, 56)


static func get_message_display_bbcode(title: String, max_width: float = 400.0) -> String:
	for font_size in range(MESSAGE_FONT_MAX, MESSAGE_FONT_MIN - 1, -4):
		if _measure_text_width(title, font_size) <= max_width:
			return _build_message_bbcode(title, font_size)
	return _build_message_bbcode(title, MESSAGE_FONT_MIN)


static func _build_message_bbcode(title: String, font_size: int) -> String:
	return "[font_size=%d][color=#FFFFFF]%s[/color][/font_size]" % [font_size, title]


static func _build_pattern_bbcode(syllable: String, condition: int, hi_size: int, dim_size: int) -> String:
	var hi := "[font_size=%d][color=#FFFFFF]%s[/color][/font_size]" % [hi_size, syllable]
	var dim := "[font_size=%d][color=#FFFFFF]%s[/color][/font_size]" % [dim_size, "%s"]
	match condition:
		Type.BEGIN:
			return hi + (dim % "___")
		Type.END:
			return (dim % "___") + hi
		Type.ANYWHERE:
			return (dim % "_") + hi + (dim % "_")
		_:
			return hi


static func _measure_text_width(text: String, font_size: int) -> float:
	var font := ThemeDB.fallback_font
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x


static func _measure_pattern_width(syllable: String, condition: int, hi_size: int, dim_size: int) -> float:
	match condition:
		Type.BEGIN:
			return _measure_text_width(syllable, hi_size) + _measure_text_width("___", dim_size)
		Type.END:
			return _measure_text_width("___", dim_size) + _measure_text_width(syllable, hi_size)
		Type.ANYWHERE:
			return _measure_text_width("_", dim_size) + _measure_text_width(syllable, hi_size) + _measure_text_width("_", dim_size)
		_:
			return _measure_text_width(syllable, hi_size)
