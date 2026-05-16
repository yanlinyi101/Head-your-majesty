extends SceneTree

const MatchRulesTests := preload("res://tests/test_match_rules.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	failures.append_array(MatchRulesTests.new().run())
	if failures.is_empty():
		print("TESTS PASSED")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)
