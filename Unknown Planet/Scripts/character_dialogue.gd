extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var timer = get_node("Timer")
onready var area = get_node("Area2D")
var can_continue = true

export var get_keycard = false

var active = false
var finished = false

export var messeges = []

var index = 0
var player

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	area.connect("body_enter", self, "on_character_dialogue_body_enter")
	timer.connect("timeout", self, "on_character_dialogue_timer_timeout")

func on_character_dialogue_timer_timeout():
	if finished:
		active = false
		finished = false
		if get_keycard:
			game_manager.blue_card = true
			game_manager.HUD.update_cards()
		player.enable()
	else:
		timer.stop()
		can_continue = true

func on_character_dialogue_body_enter(body):
	if !active and body.is_in_group("player"):
		active = true
		body.disable()
		player = body
		timer.start()
		can_continue = false
		set_process(true)
		game_manager.HUD.enable_text()
		display_current_messege()
		
func display_current_messege():
	game_manager.HUD.update_textbox(messeges[index])
	index+=1
		
func _process(delta):
	if can_continue and Input.is_action_pressed("ui_accept"):
		if index > messeges.size()-1:
			set_process(false)
			index = 0
			game_manager.HUD.hide_textbox()
			finished = true
			
		else:
			can_continue = false
			display_current_messege()
			
		timer.start()
	