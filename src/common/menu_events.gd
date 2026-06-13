class_name MenuEvents
extends Resource

@warning_ignore("unused_signal") signal ev_player_added(player_info: PlayerInfo)
@warning_ignore("unused_signal") signal ev_player_removed(player_info: PlayerInfo, player_index: int)
@warning_ignore("unused_signal") signal ev_player_modified(player_info: PlayerInfo, player_index: int)
@warning_ignore("unused_signal") signal ev_player_swapped(index_a: int, index_b: int)
@warning_ignore("unused_signal") signal ev_game_time_changed(minutes: int)
@warning_ignore("unused_signal") signal ev_player_move_begin
@warning_ignore("unused_signal") signal ev_player_move_end
