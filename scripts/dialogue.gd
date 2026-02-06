extends RichTextLabel

# Text, ktorý chceme zobraziť
var full_text : String = "Ahoj! Toto je test dialógu."
# Rýchlosť zobrazovania v sekundách na jedno písmeno
var char_delay : float = 0.05

func _ready():
	text = ""  # Na začiatku je label prázdny
	show_text(full_text)

# Funkcia na postupné zobrazovanie textu
func show_text(new_text: String) -> void:
	text = ""
	var char_index = 0
	while char_index < new_text.length():
		text += new_text[char_index]
		char_index += 1
		await get_tree().create_timer(char_delay).timeout
