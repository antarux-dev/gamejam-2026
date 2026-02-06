extends Node2D

var is_at_door = false
var is_at_door_green = false

var state = 1

@onready var e_prompt = $RedDoor/EPrompt
@onready var e_prompt1 = $BlueDoor/EPrompt

@onready var Door1 = $Room1/Door1
@onready var Door2 = $Room1/Door2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var level_container = $"."
	
func FakeSpawnTpPlayer(Position: Vector2) -> void:
	Globals.LocalPlayer.velocity = Vector2.ZERO
	Globals.LocalPlayer.global_position = Position

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

func _process(_delta: float) -> void:
	if Globals.FUCKING_ROOM_LOOP:
		pass
	
	
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
	
	if Globals.FUCKING_ROOM_LOOP:
		if is_at_door_green or is_at_door:
			FakeSpawnTpPlayer(Vector2(-30, 40))
			load_level("res://scenes/room_door.tscn")
		return
	
	if is_at_door_green and event.is_action_pressed("interact"): 
		if state == 1:
			FakeSpawnTpPlayer(Vector2(-30, 40))
			load_level("res://scenes/room_door.tscn")
			state += 1
		elif state == 2:
			FakeSpawnTpPlayer(Vector2(0, 0))
			state += 1
		elif state == 3:
			FakeSpawnTpPlayer(Vector2(-30, 40))
			load_level("res://scenes/room_door.tscn")
			state += 1
					
	if is_at_door and event.is_action_pressed("interact"):
		if state == 1:
			FakeSpawnTpPlayer(Vector2(0, 0))
			state += 1
		elif state == 2:
			FakeSpawnTpPlayer(Vector2(-30, 40))
			load_level("res://scenes/room_door.tscn")
			state += 1
		elif state == 4:
			FakeSpawnTpPlayer(Vector2(-30, 40))
			load_level("res://scenes/room_door.tscn")
			
	if is_at_door_green and state == 3:
		Door2.visible = false
		state += 1
