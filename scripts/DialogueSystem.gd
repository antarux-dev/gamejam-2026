extends CanvasLayer

# Signály pre komunikáciu s hráčom a hrou
signal dialogue_started
signal dialogue_finished

@onready var text_label = $Panel/RichTextLabel
@onready var key_prompt = $Panel/Label
@onready var audio_player = $AudioStreamPlayer

var dialogues_dict = {}     # Všetky dáta z JSONu
var dialogue_queue = []    # Poradie dialógov na prehratie
var target_key = ""        # Aktuálna troll klávesa
var is_waiting_for_key = false
var is_active = false      # Poistka, aby nebežali dva dialógy naraz

func _ready():
	key_prompt.hide()
	self.hide()
	text_label.bbcode_enabled = true # Povolenie [b] tagov
	load_dialogues()
	
	start_sequence([1])

func load_dialogues():
	var path = "res://assets/dialogs.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		
		if data == null:
			printerr("Chyba: JSON súbor má nesprávny formát!")
			return

		for item in data:
			# Ošetrenie ID (odstránenie .0 z floatov)
			var id_key = str(int(item["id"]))
			dialogues_dict[id_key] = item
		print("Dialógy úspešne načítané. Počet: ", dialogues_dict.size())
	else:
		printerr("JSON nebol nájdený na ceste: ", path)

# --- SPUSTENIE SEKVENCIÍ ---
func start_sequence(ids: Array):
	# Ak systém už pracuje, nové príkazy ignorujeme
	if is_active: 
		return 
	
	is_active = true
	dialogue_queue = ids.duplicate()
	
	# Stíšenie hudby (ak existuje)
	var bg_music = get_node_or_null("/root/game/BackgroundMusic")
	if bg_music:
		bg_music.volume_db = -30
	
	# Povieme hráčovi, aby zastavil
	dialogue_started.emit()
	self.show()
	_play_next_in_queue()

func _play_next_in_queue():
	# Ak je fronta prázdna, vypíname systém
	if dialogue_queue.is_empty():
		_close_dialogue_system()
		return
	
	var next_id = str(dialogue_queue.pop_front())
	
	if dialogues_dict.has(next_id):
		Globals.SetMove(true)
		_execute_dialogue(dialogues_dict[next_id])
	else:
		printerr("CHYBA: ID ", next_id, " v JSONe neexistuje!")
		_play_next_in_queue()

func _execute_dialogue(d):
	Globals.SetMove(false)
	# 1. NAČÍTANIE AUDIA
	var v_path = d["voice"]
	if v_path.begins_with("/"): v_path = v_path.erase(0, 1)
	var full_path = "res://assets/" + v_path
	
	if FileAccess.file_exists(full_path):
		audio_player.stream = load(full_path)
		audio_player.play()
	else:
		printerr("Audio súbor nenájdený: ", full_path)
		audio_player.stream = null

	# 2. VÝPIS TEXTU
	_display_text(d)

	# 3. PRIPOJENIE SIGNÁLOV PODĽA TYPU
	# Odpojíme staré prepojenia
	if audio_player.finished.is_connected(_on_audio_finished): audio_player.finished.disconnect(_on_audio_finished)
	if audio_player.finished.is_connected(_on_ambient_finished): audio_player.finished.disconnect(_on_ambient_finished)
	
	if d["type"] == "d": # Dialóg (čaká na klávesu)
		audio_player.finished.connect(_on_audio_finished)
	else: # Ambient (ide hneď ďalej)
		audio_player.finished.connect(_on_ambient_finished)

func _display_text(data):
	var npc_name = str(data["npc"]).capitalize() + ": "
	var raw_text = data["text"]
	
	# BBCode formátovanie
	text_label.text = "[b]" + npc_name + "[/b]" + raw_text
	
	# Reset typewriter efektu
	var name_length = npc_name.length()
	var total_length = text_label.get_total_character_count()
	text_label.visible_characters = name_length
	
	# Výpočet trvania podľa audia
	var duration = 2.0
	if audio_player.stream:
		duration = audio_player.stream.get_length()
	
	# Animácia písania textu
	var tween = create_tween()
	tween.tween_property(text_label, "visible_characters", total_length, max(0, duration - 0))

# --- UKONČENIE A LOGIKA KLÁVES ---
func _on_audio_finished():
	target_key = get_random_troll_key()
	key_prompt.text = "STLAČ [" + target_key + "] PRE POKRAČOVANIE"
	key_prompt.show()
	is_waiting_for_key = true

func _on_ambient_finished():
	# Počkáme sekundu a ideme na ďalší
	await get_tree().create_timer(1.0).timeout
	_play_next_in_queue()

func _unhandled_input(event):
	if is_waiting_for_key and event is InputEventKey and event.pressed:
		var pressed_key = OS.get_keycode_string(event.keycode)
		if pressed_key == target_key:
			is_waiting_for_key = false
			key_prompt.hide()
			_play_next_in_queue()

func _close_dialogue_system():
	self.hide()
	is_active = false
	Globals.SetMove(true)
	
	# Vrátenie hudby do normálu
	var bg_music = get_node_or_null("/root/game/BackgroundMusic")
	if bg_music:
		bg_music.volume_db = -5
		
	# Hráč sa môže znova hýbať
	dialogue_finished.emit()

func get_random_troll_key() -> String:
	var pool = [
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
		"Space", "Enter", "Shift"
	]
	return pool[randi() % pool.size()]
