extends Node3D

const EventLog := preload("res://scripts/util/event_log.gd")

var event_log: EventLog

@onready var match_controller: MatchController = $MatchController
@onready var player: CharacterActor = $Player
@onready var bot: CharacterActor = $Bot
@onready var king_head: HeadSystem = $KingHead
@onready var hud: CanvasLayer = $HUD

var actors: Array[CharacterActor] = []

func _ready() -> void:
	event_log = EventLog.new()
	add_child(event_log)
	match_controller.event_log = event_log
	actors = [player, bot]
	for actor in actors:
		match_controller.add_participant(actor.participant_id)
		actor.lunge_hit.connect(_on_lunge_hit)
		actor.severe_fall.connect(_on_severe_fall)
	king_head.worn.connect(_on_head_worn)
	king_head.loosened.connect(match_controller.on_head_became_loose)
	match_controller.score_changed.connect(func(_id, _score): hud.set_scores(match_controller.scores))
	match_controller.carrier_changed.connect(hud.set_carrier)
	match_controller.match_finished.connect(_on_match_finished)
	hud.set_scores(match_controller.scores)

func _on_match_finished(result: Dictionary) -> void:
	hud.show_result(result)
	print("PHASE 1 MATCH SUMMARY: ", event_log.summary())

func _process(_delta: float) -> void:
	hud.set_time(match_controller.match_time_remaining)
	hud.set_pickup_visible(king_head.can_pick_up(player))

func _on_head_worn(participant_id: String) -> void:
	for candidate in actors:
		candidate.set_carrier_enabled(candidate.participant_id == participant_id)
	match_controller.set_carrier(participant_id)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pickup_head") and king_head.can_pick_up(player):
		_wear_head(player)
	_check_lunge_contacts()

func _wear_head(actor: CharacterActor) -> void:
	for candidate in actors:
		candidate.set_carrier_enabled(candidate == actor)
	king_head.attach_to_carrier(actor.participant_id, actor)

func _drop_head(from_actor: CharacterActor, push_velocity: Vector3) -> void:
	if not from_actor.is_carrier:
		return
	from_actor.set_carrier_enabled(false)
	king_head.detach_from_carrier(push_velocity)

func _check_lunge_contacts() -> void:
	for attacker in actors:
		if not attacker.is_lunging():
			continue
		for target in actors:
			if target == attacker:
				continue
			if attacker.global_position.distance_to(target.global_position) <= 1.2:
				target.receive_lunge(attacker, attacker.current_impact_strength())

func _on_lunge_hit(attacker: CharacterActor, target: CharacterActor, impact: float) -> void:
	if target.is_carrier and impact >= Tuning.KNOCKOFF_IMPACT_THRESHOLD:
		var push := (target.global_position - attacker.global_position).normalized() * impact
		_drop_head(target, push)

func _on_severe_fall(actor: CharacterActor) -> void:
	if actor.is_carrier:
		_drop_head(actor, actor.velocity)
