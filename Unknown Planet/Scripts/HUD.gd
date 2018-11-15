extends CanvasLayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var cash_label = get_node("Cash").get_node("Label")
onready var healthbar = get_node("HPContainer").get_node("healthbar")
onready var shell_position = get_node("AmmoContainer").get_node("shell")
onready var textbox = get_node("TextBox").get_node("Label")
var shell_scene = preload("res://Scenes/shell.tscn")
onready var timer = get_node("Timer")
onready var anim = get_node("AnimationPlayer")
onready var black_screen = get_node("Curtain")
onready var blue_card = get_node("BlueCard")
onready var red_card = get_node("RedCard")
onready var speed_boots = get_node("SpeedBoots")

onready var pause_menu = get_node("PauseMenu")
onready var quit_button = pause_menu.get_node("QuitButton")
onready var cont_button = pause_menu.get_node("ContinueButton")

var is_paused = false
var input_timer = 0
var input_delay = 0.24

var can_pause = true

var ammo_list = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pause_menu.set_hidden(true)
	shell_position.hide()
	hide_textbox()
	anim.connect("finished", self, "on_HUD_anim_finished")
	timer.connect("timeout", self, "on_HUD_timer_timeout")
	update_cash()
	anim.play("transition_in")
	quit_button.connect("button_up", self, "on_quit_button_up")
	cont_button.connect("button_up", self, "on_cont_button_up")
	black_screen.show()
	update_cards()
	set_process(true)

func on_cont_button_up():
	is_paused = false
	get_tree().set_pause(false)
	pause_menu.set_hidden(true)

func on_quit_button_up():
	get_tree().quit()

func update_cards():
	if game_manager.blue_card:
		blue_card.show()
	else:
		blue_card.hide()
		
	if game_manager.speed_boots:
		speed_boots.show()
	else:
		speed_boots.hide()
		
	if game_manager.red_card:
		red_card.show()
	else:
		red_card.hide()

func reset_level():
	timer.start()
	
func on_HUD_anim_finished():
	pass
	
func fade_out():
	anim.play("transition_out")
	
func on_HUD_timer_timeout():
	game_manager.goto_scene("res://Scenes/"+game_manager.scenes[1]+".tscn")

func update_healthbar(hp):
	healthbar.set_scale(Vector2(hp, 1))
	
func update_textbox(new_txt):
	textbox.set_text(new_txt)
	
func enable_text():
	textbox.get_parent().set_hidden(false)
	
func hide_textbox():
	textbox.get_parent().set_hidden(true)

func update_cash():
	cash_label.set_text(str(game_manager.cash_money))
	
func update_ammo(ammo):
	for i in range(ammo_list.size()):
		ammo_list[i].hide()
	for i in range(ammo):
		ammo_list[i].show()
	

func initialize_ammo(max_ammo):
	var start_pos = get_node("AmmoContainer").get_pos()+shell_position.get_pos()
	var size = 2
	for i in range(max_ammo):
		var s = shell_scene.instance()
		add_child(s)
		s.set_pos(Vector2(start_pos.x+size*i, start_pos.y))
		s.hide()
		ammo_list.append(s)
		
func _process(delta):
	input_timer += delta
	
	if can_pause and input_timer > input_delay and Input.is_action_pressed("start"):
		is_paused = !is_paused
		input_timer = 0
		
		if is_paused:
			get_tree().set_pause(true)
			pause_menu.set_hidden(false)
		else:
			get_tree().set_pause(false)
			pause_menu.set_hidden(true)
		
