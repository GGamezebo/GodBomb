extends CanvasLayer

@export var progress_bar: ProgressBar
@export var background: CanvasGroup

const DURATION: float = 0.6


func update_progress(value: float) -> void:
	if progress_bar:
		progress_bar.value = value * 100.0


func fade_out() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "offset:y", -1920.0, DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	if background:
		tween.tween_property(background, "modulate:a", 0.0, DURATION)
	tween.finished.connect(queue_free)
