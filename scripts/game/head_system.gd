class_name HeadSystem
extends RigidBody3D

signal landed
signal worn(carrier_id: String)
signal loosened(previous_carrier_id: String)
signal reset_to_center

const Tuning := preload("res://scripts/util/tuning.gd")

enum State { DROPPING, LOOSE, WORN }

@export var drop_origin := Vector3(0, 5, 0)
@export var attach_offset := Vector3(0, 1.45, 0)

var state := State.DROPPING
var carrier_id := ""
var carrier_node: Node3D = null
var loose_seconds := 0.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	reset_to_drop()

func _physics_process(delta: float) -> void:
	if state == State.WORN and carrier_node != null:
		global_position = carrier_node.global_position + attach_offset
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	elif state == State.LOOSE:
		loose_seconds += delta
		if loose_seconds >= Tuning.HEAD_RESET_SECONDS or global_position.y < Tuning.HEAD_OUT_OF_BOUNDS_Y:
			reset_to_drop()

func mark_landed() -> void:
	if state == State.DROPPING:
		state = State.LOOSE
		loose_seconds = 0.0
		landed.emit()

func attach_to_carrier(new_carrier_id: String, new_carrier_node: Node3D) -> void:
	state = State.WORN
	carrier_id = new_carrier_id
	carrier_node = new_carrier_node
	freeze = true
	loose_seconds = 0.0
	worn.emit(carrier_id)

func detach_from_carrier(push_velocity: Vector3) -> void:
	var previous := carrier_id
	state = State.LOOSE
	carrier_id = ""
	carrier_node = null
	freeze = false
	linear_velocity = push_velocity.limit_length(Tuning.HEAD_MAX_ROLL_SPEED)
	loose_seconds = 0.0
	loosened.emit(previous)

func reset_to_drop() -> void:
	state = State.DROPPING
	carrier_id = ""
	carrier_node = null
	freeze = false
	global_position = drop_origin
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	loose_seconds = 0.0
	reset_to_center.emit()
