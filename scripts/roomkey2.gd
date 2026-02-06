extends Node2D

var is_at_door = false
var diff = 1
@onready var e_prompt = $Door/EPrompt
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
		load_level("res://scenes/between1.tscn")


func _on_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door = true
		e_prompt.show() # Zobrazíme nápis [E]

func _on_door_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_at_door = false
		e_prompt.hide()


func _on_recepcia_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player" and diff == 1:
		DialogueSystem.start_sequence([17, 18, 19])
		diff += 1
		$RecepciaTrigger.queue_free()
	else:
		printerr("Chyba: DialogueSystem nebol nájdený v hlavnej scéne!")


func _on_recepcia_trigger_2_body_entered(body: Node2D) -> void:
	if body.name == "Player" and diff == 2:
		DialogueSystem.start_sequence([20])
		diff += 1
		$RecepciaTrigger2.queue_free()
	else:
		printerr("Chyba: DialogueSystem nebol nájdený v hlavnej scéne!")


func _on_recepcia_trigger_3_body_entered(body: Node2D) -> void:
	if body.name == "Player" and diff == 3:
		DialogueSystem.start_sequence([21])
		diff += 1
		$RecepciaTrigger3.queue_free()
	else:
		printerr("Chyba: DialogueSystem nebol nájdený v hlavnej scéne!")


func _on_recepcia_trigger_4_body_entered(body: Node2D) -> void:
	if body.name == "Player" and diff == 4:
		DialogueSystem.start_sequence([22])
		diff += 1
		$RecepciaTrigger4.queue_free()
	else:
		printerr("Chyba: DialogueSystem nebol nájdený v hlavnej scéne!")


func _on_recepcia_trigger_5_body_entered(body: Node2D) -> void:
	if body.name == "Player" and diff == 5:
		DialogueSystem.start_sequence([23, 24])
		diff += 1
		$RecepciaTrigger5.queue_free()
	else:
		printerr("Chyba: DialogueSystem nebol nájdený v hlavnej scéne!")


func _on_recepcia_trigger_6_body_entered(body: Node2D) -> void:
	if body.name == "Player" and diff == 6:
		DialogueSystem.start_sequence([25, 26])
		diff += 1
		$RecepciaTrigger6.queue_free()
	else:
		printerr("Chyba: DialogueSystem nebol nájdený v hlavnej scéne!")
