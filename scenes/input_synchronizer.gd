extends MultiplayerSynchronizer

@export var move_input: float = 0
@export var jumping: bool = false

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		move_input = Input.get_axis("move_left", "move_right")
		if Input.is_action_just_pressed("jump"):
			jumping = true
	
