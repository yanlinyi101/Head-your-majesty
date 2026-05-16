extends Node

enum State { SEEK_HEAD, CHASE_CARRIER, ESCAPE_WITH_HEAD, RECOVER }

const Tuning := preload("res://scripts/util/tuning.gd")

@export var actor_path: NodePath
@export var player_path: NodePath
@export var head_path: NodePath

@onready var actor: CharacterActor = get_node(actor_path)
@onready var player: CharacterActor = get_node(player_path)
@onready var head: HeadSystem = get_node(head_path)

var state := State.SEEK_HEAD
var _lunge_timer := 0.0
var _recover_timer := 0.0

func _physics_process(delta: float) -> void:
	_lunge_timer = maxf(0.0, _lunge_timer - delta)
	match state:
		State.SEEK_HEAD:
			_seek_head()
		State.CHASE_CARRIER:
			_chase_player()
		State.ESCAPE_WITH_HEAD:
			_escape_player()
		State.RECOVER:
			_recover(delta)
	_update_state()

func _update_state() -> void:
	if state == State.RECOVER:
		return
	if actor.global_position.y < -2.0:
		state = State.RECOVER
		_recover_timer = Tuning.BOT_RECOVER_SECONDS
	elif actor.is_carrier:
		state = State.ESCAPE_WITH_HEAD
	elif player.is_carrier:
		state = State.CHASE_CARRIER
	else:
		state = State.SEEK_HEAD

func _seek_head() -> void:
	_move_toward(head.global_position)
	if head.can_pick_up(actor):
		actor.set_carrier_enabled(true)
		head.attach_to_carrier(actor.participant_id, actor)

func _chase_player() -> void:
	_move_toward(player.global_position)
	if actor.global_position.distance_to(player.global_position) <= Tuning.BOT_LUNGE_RANGE and _lunge_timer <= 0.0:
		actor.request_lunge()
		_lunge_timer = Tuning.BOT_LUNGE_INTERVAL

func _escape_player() -> void:
	var away := actor.global_position - player.global_position
	away.y = 0.0
	if away.length() < 0.1:
		away = Vector3.RIGHT
	actor.set_move_direction(away.normalized())

func _recover(delta: float) -> void:
	_recover_timer -= delta
	actor.set_move_direction(Vector3.ZERO)
	if _recover_timer <= 0.0:
		state = State.SEEK_HEAD

func _move_toward(target: Vector3) -> void:
	var direction := target - actor.global_position
	direction.y = 0.0
	actor.set_move_direction(direction.normalized())
