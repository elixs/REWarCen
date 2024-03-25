class_name Player
extends CharacterBody2D

signal picked(object)

var speed = 200
var jump_speed = 300
var gravity = 300
var acceleration = 3000
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D



@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer
@onready var line_2d: Line2D = $Line2D


@export var bullet_scene: PackedScene

@export var score = 1 :
	set(value):
		score = value
		Debug.sprint("Player %s score %d" % [name, score])

var target_path: PackedVector2Array = []

func _ready() -> void:
	line_2d.top_level = true
	line_2d.global_position = Vector2.ZERO
	picked.connect(_on_picked)

func _physics_process(delta: float) -> void:
	
	if is_multiplayer_authority():
		
		#if not navigation_agent_2d.is_navigation_finished():
			#position = navigation_agent_2d.get_next_path_position()
			
		if target_path.size():
			var target = target_path[0]
			velocity = velocity.move_toward(speed * global_position.direction_to(target), acceleration * delta)
			#NavigationServer2D.agent_set_velocity(navigation_agent_2d.get_rid(), velocity)
			if global_position.distance_to(target) <= velocity.length() * delta:
				Debug.sprint("change")
				target_path.remove_at(0)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
		move_and_slide()
	
	#if not is_on_floor():
		#velocity.y += gravity * delta
	#if is_multiplayer_authority():
		#if is_on_floor() and Input.is_action_just_pressed("jump"):
			#velocity.y = -jump_speed
		#var move_input = Input.get_axis("move_left", "move_right")
		#velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
		#send_data.rpc(global_position, velocity)
	#move_and_slide()
	#if not is_on_floor():
		#velocity.y += gravity * delta
	#if is_on_floor() and input_synchronizer.jumping:
		#velocity.y = -jump_speed
		#input_synchronizer.jumping = false
	#var move_input = input_synchronizer.move_input
	#velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	#move_and_slide()

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("click"):
			target_path = NavigationServer2D.map_get_path(get_world_2d().navigation_map, global_position, get_global_mouse_position(), true)
			line_2d.clear_points()
			
			navigation_agent_2d.set
			for pos in target_path:
				line_2d.add_point(pos)
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
	Debug.sprint(message)
	Debug.sprint(sender_player.name)

@rpc
func send_data(pos: Vector2, vel: Vector2):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	
func _on_picked(object: String):
	Debug.sprint(object)
