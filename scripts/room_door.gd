extends Node2D

var is_at_door = false
@onready var e_prompt = $Door/EPrompt
@onready var level_container = $"."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("My node path = ", self.get_path())
	print("Is inside tree? ", is_inside_tree())
	print("Process input enabled? ", is_processing_input())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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

func _on_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door = true
		e_prompt.show() # Zobrazíme nápis [E]


func _on_door_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door = false
		e_prompt.hide()

func _input(event):
	print(1)
	if Globals.FUCKING_ROOM_LOOP and is_at_door and event.is_action_pressed("interact"):
		print(2)
		FakeSpawnTpPlayer(Vector2(0, 0))
		load_level("res://scenes/roomkey2.tscn")
	elif is_at_door and event.is_action_pressed("interact"):
		print(3)
		FakeSpawnTpPlayer(Vector2(0, 0))
		load_level("res://scenes/Room1.tscn")
		Globals.FUCKING_ROOM_LOOP = true
	
