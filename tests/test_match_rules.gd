extends RefCounted

const MatchController := preload("res://scripts/game/match_controller.gd")
const EventLog := preload("res://scripts/util/event_log.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	_test_score_ticks_for_current_carrier(failures)
	_test_tie_result_has_no_tiebreaker(failures)
	_test_reversal_event_is_logged(failures)
	return failures

func _test_score_ticks_for_current_carrier(failures: Array[String]) -> void:
	var ctrl := MatchController.new()
	ctrl.add_participant("player")
	ctrl.add_participant("bot_1")
	ctrl.set_carrier("player")
	ctrl.advance_match_time(2.2)
	if ctrl.scores["player"] != 2:
		failures.append("Expected player score to tick twice after 2.2 seconds.")

func _test_tie_result_has_no_tiebreaker(failures: Array[String]) -> void:
	var ctrl := MatchController.new()
	ctrl.add_participant("player")
	ctrl.add_participant("bot_1")
	ctrl.scores["player"] = 3
	ctrl.scores["bot_1"] = 3
	var result := ctrl.finish_match()
	if not result.get("is_tie", false):
		failures.append("Expected tied scores to produce a tie result.")

func _test_reversal_event_is_logged(failures: Array[String]) -> void:
	var log := EventLog.new()
	var ctrl := MatchController.new()
	ctrl.event_log = log
	ctrl.add_participant("player")
	ctrl.add_participant("bot_1")
	ctrl.set_carrier("player")
	ctrl.on_head_became_loose("player")
	ctrl.set_carrier("bot_1")
	if log.count("reversal") != 1:
		failures.append("Expected worn-loose-different-carrier sequence to log one reversal.")
