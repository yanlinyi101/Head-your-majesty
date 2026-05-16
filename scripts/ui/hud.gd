extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var score_label: Label = %ScoreLabel
@onready var carrier_label: Label = %CarrierLabel
@onready var prompt_label: Label = %PromptLabel
@onready var result_label: Label = %ResultLabel

func set_time(seconds: float) -> void:
	var whole := int(ceil(seconds))
	timer_label.text = "%02d:%02d" % [whole / 60, whole % 60]

func set_scores(scores: Dictionary) -> void:
	var parts: Array[String] = []
	for participant_id in scores.keys():
		parts.append("%s: %d" % [participant_id, int(scores[participant_id])])
	score_label.text = "  ".join(parts)

func set_carrier(participant_id: String) -> void:
	carrier_label.text = "Carrier: none" if participant_id == "" else "Carrier: %s" % participant_id

func set_pickup_visible(visible: bool) -> void:
	prompt_label.visible = visible

func show_result(result: Dictionary) -> void:
	if result.get("is_tie", false):
		result_label.text = "Tie!"
	else:
		result_label.text = "Winner: %s" % result.get("winners", ["none"])[0]
	result_label.visible = true
