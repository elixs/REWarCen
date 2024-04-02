extends MultiplayerSynchronizer

@export var move_input: Vector2 = Vector2.ZERO
@export var jumping: bool = false

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if Input.is_action_just_pressed("jump"):
			jumping = true
	
