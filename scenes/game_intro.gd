extends Node2D


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
