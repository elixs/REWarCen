extends Node2D

var target_player: Node2D
var map_scale: float = 0.1
@onready var player: Sprite2D = $Player
@onready var map: Sprite2D = $Limits/Map


func _process(delta: float) -> void:
	if player:
		map.position = -target_player.position * map_scale
