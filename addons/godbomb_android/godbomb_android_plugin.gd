@tool
extends EditorPlugin

var _export_plugin: GodBombAndroidExportPlugin


func _enter_tree() -> void:
	_export_plugin = GodBombAndroidExportPlugin.new()
	add_export_plugin(_export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	_export_plugin = null


class GodBombAndroidExportPlugin extends EditorExportPlugin:
	const PLAY_DEPENDENCIES: PackedStringArray = [
		"com.google.android.play:review:2.0.2",
	]

	func _get_name() -> String:
		return "GodBombAndroid"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		var preset := get_export_preset()
		if preset == null or not ("play" in preset.get_custom_features()):
			return PackedStringArray()
		return PLAY_DEPENDENCIES
