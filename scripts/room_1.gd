extends Node2D

var is_at_door = false
var is_at_door_green = false
@onready var e_prompt = $RedDoor/EPrompt
@onready var e_prompt1 = $BlueDoor/EPrompt
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@onready var level_container = $"."

func load_level(level_scene_path: String):
	# odstráni aktuálny level
	for child in level_container.get_children():
		child.queue_free()

	# načíta nový level
	var level_scene = load(level_scene_path)
	var level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)

func _on_red_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door = true
		e_prompt.show() # Zobrazíme nápis [E]


func _on_red_door_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door = false
		e_prompt.hide()


func _on_blue_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door_green = true
		e_prompt1.show() # Zobrazíme nápis [E]


func _on_blue_door_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door_green = false
		e_prompt1.hide()

func _input(event):
	# Ak sme pri dverách a hráč stlačí klávesu E
	if is_at_door_green and event.is_action_pressed("interact"): 
		$"../Player".velocity = Vector2.ZERO
		$"../Player".global_position = Vector2(-30, 40) 
		load_level("res://scenes/room_door.tscn")
