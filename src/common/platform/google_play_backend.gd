class_name GooglePlayBackend
extends PlatformBackend

## Android / Google Play (export feature `play`). No ads.
## In-App Review via JavaClassWrapper; the gradle dependency comes from addons/godbomb_android.
## Diagnostics: `adb logcat -s godot` and look for "[PlayReview]".

const STATE_PATH := "user://platform_play.cfg"
const REVIEW_MIN_FINISHED_MATCHES := 3
## Debug exports ask after every finished match so the flow can be tested quickly.
const REVIEW_MIN_FINISHED_MATCHES_DEBUG := 1
const REVIEW_COOLDOWN_SECONDS := 30 * 24 * 3600
const TASK_TIMEOUT_SECONDS := 15.0
const TASK_POLL_SECONDS := 0.25

var _state := ConfigFile.new()
var _review_in_progress: bool = false


func get_id() -> String:
	return "play"


func boot() -> void:
	var err := _state.load(STATE_PATH)
	_log("boot: state load=%s finished_matches=%s" % [
		error_string(err), _state.get_value("review", "finished_matches", 0)])


func on_match_finished_return_to_menu() -> void:
	var finished: int = int(_state.get_value("review", "finished_matches", 0)) + 1
	_state.set_value("review", "finished_matches", finished)
	_state.save(STATE_PATH)
	var should := _should_request_review(finished)
	_log("match finished: count=%d request_review=%s" % [finished, should])
	if should:
		# Fire and forget: the menu transition must not wait for Play.
		_request_review()


func _min_finished_matches() -> int:
	return REVIEW_MIN_FINISHED_MATCHES_DEBUG if OS.is_debug_build() else REVIEW_MIN_FINISHED_MATCHES


func _should_request_review(finished: int) -> bool:
	if _review_in_progress or finished < _min_finished_matches():
		return false
	if OS.is_debug_build():
		return true
	var last: int = int(_state.get_value("review", "last_prompt_unix", 0))
	return int(Time.get_unix_time_from_system()) - last >= REVIEW_COOLDOWN_SECONDS


## Google decides whether the dialog is actually shown (quota); we only ask.
func _request_review() -> void:
	if not Engine.has_singleton("AndroidRuntime"):
		_log("abort: AndroidRuntime singleton missing")
		return
	var activity = Engine.get_singleton("AndroidRuntime").getActivity()
	var factory = JavaClassWrapper.wrap("com.google.android.play.core.review.ReviewManagerFactory")
	_log("activity=%s factory=%s" % [activity, factory])
	if activity == null or factory == null:
		push_warning("GooglePlayBackend: Play Review library unavailable")
		return
	_review_in_progress = true
	var manager = factory.create(activity)
	_log("manager=%s" % [manager])
	var request = manager.requestReviewFlow() if manager else null
	var ok := await _wait_task(request, "requestReviewFlow")
	if ok:
		_state.set_value("review", "last_prompt_unix", int(Time.get_unix_time_from_system()))
		_state.save(STATE_PATH)
		await _wait_task(manager.launchReviewFlow(activity, request.getResult()), "launchReviewFlow")
	_review_in_progress = false


func _wait_task(task, label: String) -> bool:
	if task == null:
		_log("%s: no task" % label)
		return false
	var waited := 0.0
	while not task.isComplete():
		if waited >= TASK_TIMEOUT_SECONDS:
			_log("%s: timeout after %.1fs" % [label, waited])
			return false
		await host.get_tree().create_timer(TASK_POLL_SECONDS, true).timeout
		waited += TASK_POLL_SECONDS
	var ok: bool = task.isSuccessful()
	var error = null if ok else task.getException()
	_log("%s: complete in %.1fs success=%s error=%s" % [label, waited, ok, error])
	return ok


func _log(message: String) -> void:
	print("[PlayReview] ", message)
