class_name GameEvents
extends Resource

@warning_ignore("unused_signal") signal ev_game_state_changed(from_state: String, to_state: String)
@warning_ignore("unused_signal") signal ev_current_player_changed(player: GamePlayer)
@warning_ignore("unused_signal") signal ev_countdown_tick_changed(seconds_left: int)
@warning_ignore("unused_signal") signal ev_alert
@warning_ignore("unused_signal") signal ev_touch_next_player
@warning_ignore("unused_signal") signal ev_touch_prev_player
@warning_ignore("unused_signal") signal ev_card_changed(card: GameCard)
