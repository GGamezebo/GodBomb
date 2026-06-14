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
