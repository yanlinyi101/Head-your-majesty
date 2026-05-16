class_name CharacterActor
extends CharacterBody3D

signal lunge_hit(attacker: CharacterActor, target: CharacterActor, impact: float)
signal severe_fall(actor: CharacterActor)

const Tuning := preload("res://scripts/util/tuning.gd")

@export var participant_id := "actor"
@export var is_bot := false

var desired_direction := Vector3.ZERO
var wants_jump := false
var wants_lunge := false
var is_carrier := false
var stability_multiplier := 1.0

var _lunge_time_remaining := 0.0
var _lunge_cooldown_remaining := 0.0
var _fall_knockoff_cooldown := 0.0

func _physics_process(delta: float) -> void:
	_lunge_cooldown_remaining = maxf(0.0, _lunge_cooldown_remaining - delta)
	_fall_knockoff_cooldown = maxf(0.0, _fall_knockoff_cooldown - delta)
	_apply_gravity(delta)
	_apply_movement(delta)
	_apply_jump()
	_apply_lunge(delta)
	_detect_severe_fall()
	move_and_slide()

func set_move_direction(world_direction: Vector3) -> void:
	desired_direction = world_direction
	desired_direction.y = 0.0
	desired_direction = desired_direction.normalized()

func request_jump() -> void:
	wants_jump = true

func request_lunge() -> void:
	wants_lunge = true

func set_carrier_enabled(enabled: bool) -> void:
	is_carrier = enabled
	stability_multiplier = Tuning.CARRIER_STABILITY_MULTIPLIER if enabled else 1.0

func receive_lunge(attacker: CharacterActor, impact: float) -> void:
	var away := global_position - attacker.global_position
	away.y = 0.0
	if away.length() < 0.01:
		away = -global_transform.basis.z
	velocity += away.normalized() * impact
	lunge_hit.emit(attacker, self, impact)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _apply_movement(delta: float) -> void:
	var speed := Tuning.PLAYER_MOVE_SPEED
	if is_bot:
		speed = Tuning.BOT_MOVE_SPEED
	if is_carrier:
		speed *= Tuning.CARRIER_SPEED_MULTIPLIER
	var target_velocity := desired_direction * speed
	velocity.x = move_toward(velocity.x, target_velocity.x, Tuning.PLAYER_ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, Tuning.PLAYER_ACCELERATION * delta)
	if desired_direction.length() > 0.01:
		var target_basis := Transform3D().looking_at(-desired_direction, Vector3.UP).basis
		global_basis = global_basis.slerp(target_basis, clampf(Tuning.PLAYER_TURN_SPEED * delta, 0.0, 1.0))

func _apply_jump() -> void:
	if wants_jump and is_on_floor():
		velocity.y = Tuning.JUMP_VELOCITY
	wants_jump = false

func _apply_lunge(delta: float) -> void:
	if wants_lunge and _lunge_cooldown_remaining <= 0.0:
		_lunge_time_remaining = Tuning.LUNGE_DURATION
		_lunge_cooldown_remaining = Tuning.LUNGE_COOLDOWN
	wants_lunge = false
	if _lunge_time_remaining > 0.0:
		_lunge_time_remaining -= delta
		var forward := -global_transform.basis.z
		velocity.x = forward.x * Tuning.LUNGE_FORCE
		velocity.z = forward.z * Tuning.LUNGE_FORCE

func _detect_severe_fall() -> void:
	if _fall_knockoff_cooldown > 0.0:
		return
	var up_dot := global_transform.basis.y.normalized().dot(Vector3.UP)
	if up_dot < Tuning.FALL_KNOCKOFF_TILT_DOT:
		_fall_knockoff_cooldown = Tuning.FALL_KNOCKOFF_COOLDOWN
		severe_fall.emit(self)
