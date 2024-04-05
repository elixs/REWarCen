extends Node2D


#var player_scene = preload("res://scenes/player.tscn")
@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var player_a: Marker2D = $SpawnPoint/PlayerA
@onready var player_b: Marker2D = $SpawnPoint/PlayerB
@onready var minimap: Node2D = $CanvasLayer/Minimap

@onready var sprite_2d: Sprite2D = $CanvasLayer/SubViewportContainer/ViewportMinimap/Sprite2D


func _ready() -> void:
	
	var texture = get_viewport().get_texture()
	sprite_2d.texture = texture
	
	for player_data in Game.players:
		var player = player_scene.instantiate()
		if player_data.role == Statics.Role.ROLE_A:
			player.global_position = player_a.global_position
		if player_data.role == Statics.Role.ROLE_B:
			player.global_position = player_b.global_position
		
		players.add_child(player)
		player.setup(player_data)
		
		if player_data.id == multiplayer.get_unique_id():
			minimap.target_player = player
		
