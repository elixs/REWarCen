extends CharacterBody2D


@export var ball_scene: PackedScene

var speed = 200
var gravity = 300
var acceleration = 3000


@onready var input: MultiplayerSynchronizer = $InputSynchronizer
@onready var ball_spawn_point: Marker2D = $BallSpawnPoint
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

func _physics_process(delta: float) -> void:
	var move_input = input.move_input
	velocity = velocity.move_toward(move_input * speed, acceleration * delta)
	move_and_slide()
	if is_multiplayer_authority():
		pass


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("fire"):
			spawn_ball.rpc_id(1)


func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	#set_multiplayer_authority(player_data.id, true)
	input.set_multiplayer_authority(player_data.id)


@rpc("any_peer", "call_local")
func spawn_ball():
	if not ball_scene:
		return
	var ball_inst = ball_scene.instantiate()
	#ball_inst.set_multiplayer_authority(1, true)
	ball_inst.global_position = ball_spawn_point.global_position
	multiplayer_spawner.add_child(ball_inst, true)
	ball_inst.modulate = Color.RED
