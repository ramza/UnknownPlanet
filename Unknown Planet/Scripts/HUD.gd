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
onready var black_screen = get_node("Sprite")
onready var blue_card = get_node("BlueCard")

var ammo_list = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	shell_position.hide()
	hide_textbox()
	anim.connect("finished", self, "on_HUD_anim_finished")
	timer.connect("timeout", self, "on_HUD_timer_timeout")
	update_cash()
	anim.play("transition_in")
	black_screen.show()
	update_cards()
	
func update_cards():
	if game_manager.blue_card:
		blue_card.show()
	else:
		blue_card.hide()

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
