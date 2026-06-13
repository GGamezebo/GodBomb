class_name GameCard
extends RefCounted

var word: String
var condition: int


func _init(p_word: String, p_condition: int) -> void:
	word = p_word
	condition = p_condition
