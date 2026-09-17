class_name DisplayFacing
extends RefCounted

## Seat layout matches lobby chairs: index 0 at +X, then CCW.
## Dial content rotates as a group around the bomb dial center.

const TWEEN_DURATION := 0.48
const TWEEN_DURATION_CHOICE := 0.14


static func dial_center() -> Vector2:
	return BombDialLayout.GLASS_DESIGN_POSITION + BombDialLayout.GLASS_DESIGN_SIZE * 0.5


static func seat_angle(index: int, player_count: int) -> float:
	if player_count <= 0:
		return 0.0
	var wrapped := posmod(index, player_count)
	return float(wrapped) * TAU / float(player_count)


static func rotation_for_seat(index: int, player_count: int) -> float:
	return seat_angle(index, player_count) - PI * 0.5


static func shortest_delta(from_angle: float, to_angle: float) -> float:
	return wrapf(to_angle - from_angle, -PI, PI)
