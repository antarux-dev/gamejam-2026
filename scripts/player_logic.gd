class_name Player extends CharacterBody2D;

var default_speed: float = 160+.0;

var cardinal_direction: Vector2 = Vector2.DOWN;
var direction: Vector2 = Vector2.ZERO;

var movement_state: String = "idle";

@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var sprite: Sprite2D = $Sprite2D;
func _ready():
	DialogueSystem.dialogue_started.connect(func(): Globals.can_move = false)
	DialogueSystem.dialogue_finished.connect(func(): Globals.can_move = true)
	
# run service frame process
func _process(_delta: float) -> void:
	if not Globals.can_move:
		return
	direction.x = Input.get_action_strength("movement_right") - Input.get_action_strength("movement_left");
	direction.y = Input.get_action_strength("movement_down") - Input.get_action_strength("movement_up");
	
	velocity = direction * default_speed;
	
	if SetState() == true || SetDirection() == true:
		UpdateAnimations();
	pass;

	
func _physics_process(_delta: float) -> void:
	if not Globals.can_move:
		direction = Vector2.ZERO # Vynulujeme smer
		velocity = Vector2.ZERO  # Zastavíme fyziku
		return
	
	move_and_slide();
	print(sprite.scale)
	pass;
	
func SetDirection() -> bool:
	var new_dir: Vector2 = cardinal_direction;
	if direction == Vector2.ZERO:
		return false;
	
	if direction.y == 0:
		if direction.x < 0:
			new_dir = Vector2.LEFT;
		else:
			new_dir = Vector2.RIGHT;
	elif direction.x == 0:
		if direction.y < 0:
			new_dir = Vector2.UP;
		else:
			new_dir = Vector2.DOWN;
			
	if new_dir == cardinal_direction:
		return false;
	
	cardinal_direction = new_dir;
	
	if cardinal_direction == Vector2.LEFT:
		sprite.scale.x = -2;
	else:
		sprite.scale.x = 2;
	
	
	return true;
	
func SetState() -> bool:
	var new_state: String;
	if direction == Vector2.ZERO:
		new_state = "idle";
	else:
		new_state = "walk";
	
	if new_state == movement_state:
		return false;
		
	movement_state = new_state;
	return true;
	
func UpdateAnimations() -> void:
	animation_player.play(movement_state + "_" + AnimDirection());
	pass;
	
func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down";
	elif cardinal_direction == Vector2.UP:
		return "up";
	else:
		return "side";
