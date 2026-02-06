extends Camera2D

@export var target: Node2D = get_parent();
@export var smooth_speed: float = 5.0

func _ready():
	make_current()

func _process(delta):
	if target:
		global_position = global_position.lerp(target.global_position, smooth_speed * delta)
