extends CanvasLayer

@onready var text_label = $Panel/RichTextLabel
@onready var key_prompt = $Panel/Label
@onready var audio_player = $AudioStreamPlayer

var dialogues_dict = {}     # Slovník všetkých dialógov načítaných z JSONu
var dialogue_queue = []    # Fronta IDčiek, ktoré sa majú postupne prehrať
var target_key = ""
var is_waiting_for_key = false

func _ready():
	key_prompt.hide()
	self.hide() # Systém je na začiatku skrytý
	load_dialogues()

func load_dialogues():
	var path = "res://assets/dialogs.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		# Prevedieme pole na slovník pre rýchle vyhľadávanie podľa ID
		for item in data:
			dialogues_dict[str(item["id"])] = item
		print("Dialógy úspešne načítané.")
	else:
		printerr("JSON nebol nájdený na ceste: ", path)

# --- HLAVNÁ FUNKCIA NA SPUSTENIE DIALÓGU ZVONKU ---
#ids: pole IDčiek, napr. [1] alebo [2, 3]
func start_sequence(ids: Array):
	if self.visible: 
		return # Ak už niečo hrá, ignorujeme nové požiadavky
	
	dialogue_queue = ids.duplicate() # Skopírujeme IDčka do fronty
	self.show() # Zobrazíme panel
	_play_next_in_queue()

func _play_next_in_queue():
	if dialogue_queue.is_empty():
		self.hide() # Ak už nie sú žiadne dialógy vo fronte, skryjeme systém
		return
	
	var next_id = str(dialogue_queue.pop_front()) # Vyberieme prvé ID z fronty
	
	if dialogues_dict.has(next_id):
		_execute_dialogue(dialogues_dict[next_id])
	else:
		printerr("ID dialógu neexistuje: ", next_id)
		_play_next_in_queue() # Skúsime ďalší, ak toto ID chýba

func _execute_dialogue(d):
	# 1. AUDIO LOGIKA
	var v_path = d["voice"]
	if v_path.begins_with("/"): v_path = v_path.erase(0, 1)
	var full_voice_path = "res://assets/" + v_path
	
	if FileAccess.file_exists(full_voice_path):
		audio_player.stream = load(full_voice_path)
		audio_player.play()
	
	# 2. TEXTOVÁ LOGIKA (Typewriter s okamžitým menom)
	_display_text(d)
	
	# 3. SIGNÁLY
	if audio_player.finished.is_connected(_on_audio_finished): audio_player.finished.disconnect(_on_audio_finished)
	if audio_player.finished.is_connected(_on_ambient_finished): audio_player.finished.disconnect(_on_ambient_finished)
	
	if d["type"] == "d":
		audio_player.finished.connect(_on_audio_finished)
	else:
		audio_player.finished.connect(_on_ambient_finished)

func _display_text(data):
	var npc_name = str(data["npc"]).capitalize() + ": "
	var raw_text = data["text"]
	
	text_label.text = "[b]" + npc_name + "[/b]" + raw_text
	
	var name_length = npc_name.length()
	var total_length = text_label.get_total_character_count()
	
	# Meno ukážeme hneď
	text_label.visible_characters = name_length
	
	var audio_length = 2.0
	if audio_player.stream:
		audio_length = audio_player.stream.get_length()
	
	var tween_duration = max(0.2, audio_length - 0.1)
	
	var tween = create_tween()
	tween.tween_property(text_label, "visible_characters", total_length, tween_duration)

func _on_audio_finished():
	target_key = get_random_troll_key()
	key_prompt.text = "STLAČ [" + target_key + "] PRE POKRAČOVANIE"
	key_prompt.show()
	is_waiting_for_key = true

func _on_ambient_finished():
	# Ambientné hlášky automaticky idú na ďalší dialóg vo fronte
	_play_next_in_queue()

func get_random_troll_key() -> String:
	var letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	var numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	var symbols = ["Space", "Enter", "Escape", "Comma", "Period", "Slash", "Minus", "Equal"]
	
	var pool = letters + numbers + symbols
	return pool[randi() % pool.size()]

func _unhandled_input(event):
	if is_waiting_for_key and event is InputEventKey and event.pressed:
		var pressed_key = OS.get_keycode_string(event.keycode)
		if pressed_key == target_key:
			is_waiting_for_key = false
			key_prompt.hide()
			_play_next_in_queue() # Po úspešnom stlačení ideme na ďalší
