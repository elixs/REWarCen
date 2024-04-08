extends Area2D


var speed = 500


func _ready() -> void:
	if is_multiplayer_authority():
		await get_tree().create_timer(1).timeout
		queue_free()


func _physics_process(delta: float) -> void:
	var velocity = speed * transform.x
	position += velocity * delta
