class_name PlatformBackend
extends RefCounted

## Store/portal adapter used by the PlatformServices facade.
## Every hook is a safe no-op here; subclasses override only what their platform needs.

const PRIVACY_POLICY_URL := "https://igorion.itch.io/tic-tac-bada-boom-privacy"

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


## Called on every press (touch / mouse / key) that reaches the game.
func on_user_input() -> void:
	pass


## Empty string hides the in-game link (portals that forbid external links).
func privacy_policy_url() -> String:
	return PRIVACY_POLICY_URL
