class_name GooglePlayBackend
extends PlatformBackend

## Android / Google Play (export feature `play`). No ads.
## In-App Review via JavaClassWrapper; the gradle dependency comes from addons/godbomb_android.

const STATE_PATH := "user://platform_play.cfg"
const REVIEW_MIN_FINISHED_MATCHES := 3
const REVIEW_COOLDOWN_SECONDS := 30 * 24 * 3600
const TASK_TIMEOUT_SECONDS := 15.0
const TASK_POLL_SECONDS := 0.25

var _state := ConfigFile.new()
var _review_in_progress: bool = false


func get_id() -> String:
	return "play"


func boot() -> void:
	_state.load(STATE_PATH)


func on_match_finished_return_to_menu() -> void:
	var finished: int = int(_state.get_value("review", "finished_matches", 0)) + 1
	_state.set_value("review", "finished_matches", finished)
	_state.save(STATE_PATH)
	if _should_request_review(finished):
		# Fire and forget: the menu transition must not wait for Play.
		_request_review()


func _should_request_review(finished: int) -> bool:
	if _review_in_progress or finished < REVIEW_MIN_FINISHED_MATCHES:
		return false
	var last: int = int(_state.get_value("review", "last_prompt_unix", 0))
	return int(Time.get_unix_time_from_system()) - last >= REVIEW_COOLDOWN_SECONDS


## Google decides whether the dialog is actually shown (quota); we only ask.
func _request_review() -> void:
	if not Engine.has_singleton("AndroidRuntime"):
		return
	var activity = Engine.get_singleton("AndroidRuntime").getActivity()
	var factory = JavaClassWrapper.wrap("com.google.android.play.core.review.ReviewManagerFactory")
	if activity == null or factory == null:
		push_warning("GooglePlayBackend: Play Review library unavailable")
		return
	_review_in_progress = true
	var manager = factory.create(activity)
	var request = manager.requestReviewFlow()
	if await _wait_task(request):
		_state.set_value("review", "last_prompt_unix", int(Time.get_unix_time_from_system()))
		_state.save(STATE_PATH)
		await _wait_task(manager.launchReviewFlow(activity, request.getResult()))
	_review_in_progress = false


func _wait_task(task) -> bool:
	if task == null:
		return false
	var waited := 0.0
	while not task.isComplete():
		if waited >= TASK_TIMEOUT_SECONDS:
			return false
		await host.get_tree().create_timer(TASK_POLL_SECONDS, true).timeout
		waited += TASK_POLL_SECONDS
	return task.isSuccessful()
