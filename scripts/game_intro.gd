extends Node2D

var is_at_door = false
@onready var e_prompt = $Door/EPrompt
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
		change_room()

func change_room():
	get_tree().change_scene_to_file("res://scenes/Room1.tscn")


func _on_door_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player":
		is_at_door = false
		e_prompt.hide() # Schováme nápis [E]pass # Replace with function body.
