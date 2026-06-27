class_name BattleExplanationBannerLayout
extends RefCounted

const PANEL_SCREEN_MARGIN := Vector2(32.0, 64.0)


static func apply(banner: Control, layout_host: MenuBombLayout, height: float) -> void:
	if not banner or not layout_host:
		return
	var scale := layout_host.get_cover_scale()
	if scale <= 0.0:
		return
	var host_size := layout_host.size
	var offset := (host_size - MenuBombLayout.DESIGN_SIZE * scale) * 0.5
	var left := (PANEL_SCREEN_MARGIN.x - offset.x) / scale
	var right := (host_size.x - PANEL_SCREEN_MARGIN.x - offset.x) / scale
	var top := (PANEL_SCREEN_MARGIN.y - offset.y) / scale
	banner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	banner.offset_left = left
	banner.offset_top = top
	banner.offset_right = right
	banner.offset_bottom = top + height
