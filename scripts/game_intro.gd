extends Node2D

var is_at_door = false
@onready var e_prompt = $Door/EPrompt
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


@onready var level_container = $"."

func load_level(level_scene_path: String):
	# odstráni aktuálny level
	for child in level_container.get_children():
		child.queue_free()

	# načíta nový level
	var level_scene = load(level_scene_path)
	var level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)


func _on_recepcia_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Hľadáme DialogueSystem v "rodičovskej" scéne (game.tscn)
		var ds = get_parent().get_node("DialogueSystem")
		
		if ds:
			ds.start_sequence([2, 3, 4])
			$RecepciaTrigger.queue_free()
		else:
			printerr("Chyba: DialogueSystem nebol nájdený v hlavnej scéne!")


func _on_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door = true
		e_prompt.show() # Zobrazíme nápis [E]

func _input(event):
	# Ak sme pri dverách a hráč stlačí klávesu E
	if is_at_door and event.is_action_pressed("interact"): 
		$"../Player".velocity = Vector2.ZERO
		$"../Player".global_position = Vector2(-30, 40) 
		load_level("res://scenes/Room1.tscn")

func change_room():
	get_tree().change_scene_to_file("res://scenes/Room1.tscn")


func _on_door_body_shape_exited(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "Player":
		is_at_door = false
		e_prompt.hide() # Schováme nápis [E]pass # Replace with function body.
