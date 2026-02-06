extends Node2D

var is_at_door = false
var is_at_wrong_door = false
@onready var e_prompt = $Door/EPrompt
@onready var e_prompt2 = $Door2/EPrompt
@onready var e_prompt3 = $Door3/EPrompt
@onready var level_container = $"."

func load_level(level_scene_path: String):
	# odstráni aktuálny level
	for child in level_container.get_children():
		child.queue_free()

	# načíta nový level
	var level_scene = load(level_scene_path)
	var level_instance = level_scene.instantiate()
	level_container.add_child(level_instance)

func _input(event):
	# Ak sme pri dverách a hráč stlačí klávesu E
	if is_at_door and event.is_action_pressed("interact"): 
		Globals.LocalPlayer.velocity = Vector2.ZERO
		Globals.LocalPlayer.global_position = Vector2(-30, 40)
		load_level("res://scenes/final.tscn")
	
	if is_at_wrong_door and event.is_action_pressed("interact"):
		Globals.LocalPlayer.visibility = false
		DialogueSystem.start_sequence([30])

# winning dvere
func _on_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door = true
		e_prompt.show() # Zobrazíme nápis [E]

func _on_door_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door = false
		e_prompt.hide()

# dajaco zle
func _on_door_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_at_wrong_door = true
		e_prompt2.hide()


func _on_door_2_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_at_wrong_door = false
		e_prompt2.hide()

# dajaco zle 2
func _on_door_3_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_at_wrong_door = true
		e_prompt3.hide()

func _on_door_3_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_at_wrong_door = false
		e_prompt3.hide()


func _on_recepcia_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		DialogueSystem.start_sequence([29])
		$RecepciaTrigger.queue_free()
	else:
		printerr("Chyba: DialogueSystem nebol nájdený v hlavnej scéne!")
