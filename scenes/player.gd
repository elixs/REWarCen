class_name Player
extends CharacterBody2D

signal picked(object)
signal health_changed(value)
signal fired(slash)

@export var bullet_scene: PackedScene

@export var score = 1 :
	set(value):
		score = value
		Debug.log("Player %s score %d" % [name, score])

@export var slash_scene: PackedScene
var speed = 200
var jump_speed = 300
var gravity = 300
var acceleration = 3000
var health = 100:
	set(value):
		health = value
		health_changed.emit(health)
var max_health = 100
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer
@onready var line_2d: Line2D = $Line2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var gui: CanvasLayer = $GUI


var target_path: PackedVector2Array = []

func _ready() -> void:
	line_2d.top_level = true
	line_2d.global_position = Vector2.ZERO
	picked.connect(_on_picked)
	camera_2d.enabled = false
	gui.update_health(health)
	health_changed.connect(gui.update_health)
	gui.hide()

func _physics_process(delta: float) -> void:
	var move_input = input_synchronizer.move_input
	var target_velocity = move_input * speed
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	move_and_slide()
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("fire"):
			Debug.log(multiplayer.get_unique_id())
			fire.rpc_id(1, get_global_mouse_position())

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("click"):
			navigation_agent_2d.target_position = get_global_mouse_position()
			#line_2d.clear_points()
			
			#navigation_agent_2d.set
			#for pos in target_path:
				#line_2d.add_point(pos)
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			health -= 10
			# triggers syncronizer
			score += 1

func setup(player_data: Statics.PlayerData):
	
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	multiplayer_spawner.set_multiplayer_authority(player_data.id)
	multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	input_synchronizer.set_multiplayer_authority(player_data.id)
	
	if multiplayer.get_unique_id() == player_data.id:
		camera_2d.enabled = true
		gui.show()

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


@rpc("call_local")
func fire(mouse_position) -> void:
	Debug.log(multiplayer.get_unique_id())
	var slash_inst = slash_scene.instantiate()
	slash_inst.global_rotation = global_position.direction_to(mouse_position).angle()
	slash_inst.global_position = global_position
	fired.emit(slash_inst)
