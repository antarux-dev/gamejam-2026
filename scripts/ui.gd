extends CanvasLayer

# Menu nodes 
@onready var menu: Control = $Control/Menu
@onready var best_label: Label = $Control/Menu/Label2
@onready var game_name: Label = $Control/Menu/Label
@onready var start_button: Button = $Control/Menu/Button

# HUD nodes
@onready var hud: Control = $Control/HUD
@onready var time_label: Label = $Control/HUD/TimeLabel

# Pause nodes
@onready var pause_menu: Control = $Control/Pause
@onready var continue_button: Button = $Control/Pause/Button
@onready var exit_button: Button = $Control/Pause/Button2

var game_time: float = 0.0
var is_game_active: bool = false
var best_time: float = 1e10

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	load_best_time()
	update_best_display()
	
	menu.visible = true
	hud.visible = false
	pause_menu.visible = false
	
	get_tree().paused = true
	
	_startanimation()
	
	$Control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Prilepí HUD do pravého horného rohu
	hud.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	# Odstupy od okrajov (uprav si čísla podľa potreby)
	hud.offset_left = -1200   # Posun doľava, aby bol HUD vidieť
	hud.offset_right = -10   # Malá medzera od pravého okraja
	hud.offset_top = 10      # Malá medzera od horného okraja
	
	for panel in [$Control/Menu/ColorRec, $Control/HUD/ColorRec, $Control/Pause/ColorRec]:
		if panel is ColorRect:
			panel.anchor_right   = 1.0
			panel.anchor_top   = 1.0
			panel.anchor_bottom  = 1.0
			panel.offset_right   = 0
			panel.offset_top   = 0
			panel.offset_bottom  = 0


func _process(delta: float) -> void:
	if is_game_active:
		game_time += delta
		time_label.text = format_time(game_time)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if menu.visible:
			get_tree().quit()
		elif pause_menu.visible:
			_on_continue_pressed()
		else:
			pause_game()


func _on_start_pressed() -> void:
	menu.visible = false
	hud.visible = true
	pause_menu.visible = false
	
	is_game_active = true
	game_time = 0.0
	get_tree().paused = false


func pause_game() -> void:
	is_game_active = false
	get_tree().paused = true
	pause_menu.visible = true
	hud.visible = true


func _on_continue_pressed() -> void:
	pause_menu.visible = false
	is_game_active = true
	get_tree().paused = false


func _on_exit_pressed() -> void:
	if game_time < best_time and game_time > 0.1:
		best_time = game_time
		save_best_time()
		update_best_display()
	
	game_time = 0.0
	is_game_active = false
	hud.visible = false
	pause_menu.visible = false
	menu.visible = true
	get_tree().paused = true

func format_time(t: float) -> String:
	var minutes := int(t / 60)
	var seconds := int(t) % 60
	var centi := int((t - int(t)) * 100)
	return "%02d:%02d:%02d" % [minutes, seconds, centi]


func update_best_display() -> void:
	if best_time < 1e10:
		best_label.text = "Best: " + format_time(best_time)
	else:
		best_label.text = "Best: --:--:--"


func load_best_time() -> void:
	var config = ConfigFile.new()
	if config.load("user://best_time.cfg") == OK:
		best_time = config.get_value("game", "best_time", 1e10)


func save_best_time() -> void:
	var config = ConfigFile.new()
	config.set_value("game", "best_time", best_time)
	config.save("user://best_time.cfg")

func _startanimation() -> void:
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(game_name, "position:y", -8, 1.8).as_relative()
	tween.tween_property(game_name, "position:y", +8, 1.8).as_relative()
