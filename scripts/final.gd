extends Node

func _on_recepcia_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		DialogueSystem.start_sequence([31])
		$RecepciaTrigger.queue_free()
	else:
		printerr("Chyba: DialogueSystem nebol nájdený v hlavnej scéne!")
