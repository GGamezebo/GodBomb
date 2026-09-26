class_name PlatformBackend
extends RefCounted

## Store/portal adapter used by the PlatformServices facade.
## Every hook is a safe no-op here; subclasses override only what their platform needs.

var host: Node


func setup(host_node: Node) -> void:
	host = host_node


func get_id() -> String:
	return "null"


## Called once after the facade is in the tree. May await.
func boot() -> void:
	pass


func set_gameplay_active(_active: bool) -> void:
	pass


## Called when leaving the battle after a finished match (RESULT reached). May await.
func on_match_finished_return_to_menu() -> void:
	pass


func on_history_back() -> void:
	pass
