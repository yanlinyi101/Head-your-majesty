extends Node

@export var actor_path: NodePath
@export var camera_pivot_path: NodePath
@export var mouse_sensitivity := 0.003

@onready var actor: CharacterActor = get_node(actor_path)
@onready var camera_pivot: Node3D = get_node(camera_pivot_path)

var _yaw := 0.0
var _pitch := -0.35

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch = clampf(_pitch - event.relative.y * mouse_sensitivity, -0.9, 0.2)
	if event.is_action_pressed("jump"):
		actor.request_jump()
	if event.is_action_pressed("lunge"):
		actor.request_lunge()

func _physics_process(_delta: float) -> void:
	actor.rotation.y = _yaw
	camera_pivot.rotation = Vector3(_pitch, 0.0, 0.0)
	var input := Vector2.ZERO
	input.y -= Input.get_action_strength("move_forward")
	input.y += Input.get_action_strength("move_back")
	input.x -= Input.get_action_strength("move_left")
	input.x += Input.get_action_strength("move_right")
	var forward := -actor.global_transform.basis.z
	var right := actor.global_transform.basis.x
	forward.y = 0.0
	right.y = 0.0
	var world_direction := (forward.normalized() * -input.y) + (right.normalized() * input.x)
	actor.set_move_direction(world_direction)
