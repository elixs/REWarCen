class_name RTSPlayer
extends CharacterBody2D

signal picked(object)

@export var bullet_scene: PackedScene

@export var score = 1 :
	set(value):
		score = value
		Debug.log("Player %s score %d" % [name, score])

var speed = 200
var jump_speed = 300
var gravity = 300
var acceleration = 3000


@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer


func _ready() -> void:
	picked.connect(_on_picked)
	navigation_agent_2d.velocity_computed.connect(_on_velocity_computed)


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if navigation_agent_2d.is_navigation_finished():
			return
		# next path position
		var direction = global_position.direction_to(navigation_agent_2d.get_next_path_position())
		var target_velocity = direction * speed
		# obstacle avoidance
		navigation_agent_2d.velocity = target_velocity


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("click"):
			navigation_agent_2d.target_position = get_global_mouse_position()
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc(Game.get_current_player().name)
			var bullet = bullet_scene.instantiate()
			# spawner will spawn a bullet on every simulated
			multiplayer_spawner.add_child(bullet, true)
			# triggers syncronizer
			score += 1

func setup(player_data: Statics.PlayerData):
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	input_synchronizer.set_multiplayer_authority(player_data.id)

@rpc("authority", "call_local", "reliable")
func test(name):
	var message = "test " + name
	var sender_id = multiplayer.get_remote_sender_id()
	var sender_player = Game.get_player(sender_id)
	Debug.log(message)
	Debug.log(sender_player.name)

@rpc
func send_data(pos: Vector2, vel: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)

func _on_picked(object: String):
	Debug.log(object)


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
