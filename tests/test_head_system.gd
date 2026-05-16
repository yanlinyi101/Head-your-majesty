extends RefCounted

const HeadSystem := preload("res://scripts/game/head_system.gd")

func run() -> Array[String]:
	var failures: Array[String] = []
	_test_pickup_sets_carrier(failures)
	_test_detach_returns_to_loose(failures)
	_test_reset_restores_drop_position(failures)
	return failures

func _test_pickup_sets_carrier(failures: Array[String]) -> void:
	var head := HeadSystem.new()
	head.drop_origin = Vector3(0, 5, 0)
	head.mark_landed()
	head.attach_to_carrier("player", Node3D.new())
	if head.state != HeadSystem.State.WORN:
		failures.append("Expected head to enter WORN state after attach.")
	if head.carrier_id != "player":
		failures.append("Expected carrier_id to be player after attach.")

func _test_detach_returns_to_loose(failures: Array[String]) -> void:
	var head := HeadSystem.new()
	head.mark_landed()
	head.attach_to_carrier("player", Node3D.new())
	head.detach_from_carrier(Vector3.RIGHT)
	if head.state != HeadSystem.State.LOOSE:
		failures.append("Expected head to return to LOOSE state after detach.")
	if head.carrier_id != "":
		failures.append("Expected carrier_id to clear after detach.")

func _test_reset_restores_drop_position(failures: Array[String]) -> void:
	var head := HeadSystem.new()
	head.drop_origin = Vector3(1, 6, 2)
	head.position = Vector3(9, -12, 9)
	head.reset_to_drop()
	if head.position != head.drop_origin:
		failures.append("Expected reset_to_drop to move head to drop origin.")
	if head.state != HeadSystem.State.DROPPING:
		failures.append("Expected reset_to_drop to enter DROPPING state.")
