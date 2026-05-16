class_name EventLog
extends Node

var events: Array[Dictionary] = []

func record(event_type: String, payload: Dictionary = {}) -> void:
	var entry := payload.duplicate()
	entry["type"] = event_type
	entry["time_msec"] = Time.get_ticks_msec()
	events.append(entry)

func count(event_type: String) -> int:
	var total := 0
	for event in events:
		if event.get("type") == event_type:
			total += 1
	return total

func clear() -> void:
	events.clear()

func summary() -> Dictionary:
	return {
		"reversals": count("reversal"),
		"match_finished": count("match_finished"),
		"total_events": events.size()
	}
