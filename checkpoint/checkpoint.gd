extends Node2D


@export var player_scene: PackedScene
@export var ball_scene: PackedScene


@onready var player_a: Marker2D = $PlayerA
@onready var player_b: Marker2D = $PlayerB
@onready var timer: Timer = $Timer
@onready var balls: Node2D = $Balls


func _ready() -> void:
	
	if not player_scene:
		return
	for player_data in Game.players:
		var player_inst = player_scene.instantiate()
		if player_data.role == Statics.Role.ROLE_A:
			player_inst.global_position = player_a.global_position
		if player_data.role == Statics.Role.ROLE_B:
			player_inst.global_position = player_b.global_position
		add_child(player_inst)
		player_inst.setup(player_data)
		
	if is_multiplayer_authority():
		timer.timeout.connect(_spawn_ball)


func _spawn_ball():
	if not ball_scene:
		return
	var ball_inst = ball_scene.instantiate()
	#ball_inst.set_multiplayer_authority(1, true)
	ball_inst.global_position = Vector2(randf_range(100, 500), randf_range(100, 500))
	balls.add_child(ball_inst, true)
	ball_inst.modulate = Color.RED
