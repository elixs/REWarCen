extends Area2D

@onready var label: Label = $Label


var can_be_picked = false
var player


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup") and can_be_picked:
		player.picked.emit(name)
		picked.rpc()

func _on_body_entered(body: Node2D):
	player = body
	label.show()
	can_be_picked = true

func _on_body_exited(body: Node2D):
	player = null
	label.hide()
	can_be_picked = false
	
@rpc("any_peer", "call_local")
func picked():
	queue_free()
