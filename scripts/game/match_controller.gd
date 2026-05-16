class_name MatchController
extends Node

signal score_changed(participant_id: String, score: int)
signal carrier_changed(participant_id: String)
signal match_finished(result: Dictionary)

const Tuning := preload("res://scripts/util/tuning.gd")

var event_log: Node = null
var scores: Dictionary = {}
var current_carrier_id := ""
var last_loose_from_id := ""
var match_time_remaining := Tuning.MATCH_SECONDS
var _score_accumulator := 0.0
var _finished := false

func add_participant(participant_id: String) -> void:
	if not scores.has(participant_id):
		scores[participant_id] = 0

func set_carrier(participant_id: String) -> void:
	if _finished:
		return
	if participant_id != "" and not scores.has(participant_id):
		add_participant(participant_id)
	if last_loose_from_id != "" and participant_id != "" and participant_id != last_loose_from_id:
		_record("reversal", {
			"from": last_loose_from_id,
			"to": participant_id
		})
		last_loose_from_id = ""
	current_carrier_id = participant_id
	carrier_changed.emit(participant_id)

func clear_carrier() -> void:
	current_carrier_id = ""
	carrier_changed.emit("")

func on_head_became_loose(previous_carrier_id: String) -> void:
	last_loose_from_id = previous_carrier_id
	clear_carrier()

func advance_match_time(delta: float) -> void:
	if _finished:
		return
	match_time_remaining = maxf(0.0, match_time_remaining - delta)
	if current_carrier_id != "":
		_score_accumulator += delta
		while _score_accumulator >= 1.0:
			_score_accumulator -= 1.0
			scores[current_carrier_id] = int(scores.get(current_carrier_id, 0)) + Tuning.SCORE_PER_SECOND
			score_changed.emit(current_carrier_id, scores[current_carrier_id])
	if match_time_remaining <= 0.0:
		finish_match()

func finish_match() -> Dictionary:
	if _finished:
		return _build_result()
	_finished = true
	var result := _build_result()
	_record("match_finished", result)
	match_finished.emit(result)
	return result

func _build_result() -> Dictionary:
	var highest := -1
	var winners: Array[String] = []
	for participant_id in scores.keys():
		var score := int(scores[participant_id])
		if score > highest:
			highest = score
			winners = [participant_id]
		elif score == highest:
			winners.append(participant_id)
	return {
		"highest_score": highest,
		"winners": winners,
		"is_tie": winners.size() > 1
	}

func _record(event_type: String, payload: Dictionary) -> void:
	if event_log != null and event_log.has_method("record"):
		event_log.record(event_type, payload)
