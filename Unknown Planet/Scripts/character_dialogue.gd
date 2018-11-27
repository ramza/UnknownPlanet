extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var timer = get_node("Timer")
onready var area = get_node("Area2D")
onready var sample_player = get_node("SamplePlayer2D")
var can_continue = true

export var heal_player = false
export var get_keycard = false
export var get_red_keycard = false

var active = false
var finished = false


export var messeges = []
export var alt_messege = "Try to help the others."

var index = 0
var player

func _ready():
	if get_keycard and game_manager.blue_card:
		queue_free()
	elif get_red_keycard and game_manager.red_card:
		queue_free()
	# Called every time the node is added to the scene.
	# Initialization here
	area.connect("body_enter", self, "on_character_dialogue_body_enter")
	timer.connect("timeout", self, "on_character_dialogue_timer_timeout")

func on_character_dialogue_timer_timeout():
	timer.stop()
	if finished:
		active = false
		finished = false
		if (get_keycard and !game_manager.blue_card) or (get_red_keycard and !game_manager.red_card):
			if get_keycard: 
				game_manager.blue_card = true
			elif get_red_keycard:
				game_manager.red_card = true
			game_manager.HUD.update_cards()
			sample_player.play("powerup")
		player.enable()
	else:
		can_continue = true

func on_character_dialogue_body_enter(body):
	if !active and body.is_in_group("player"):
		if heal_player:
			game_manager.player.hp = game_manager.player.max_hp
			game_manager.player.update_healthbar()
		active = true
		body.disable()
		player = body
		timer.start()
		can_continue = false
		set_process(true)
		game_manager.HUD.enable_text()
		
		if (get_keycard and game_manager.blue_card) or (get_red_keycard and game_manager.red_card):
			game_manager.HUD.update_textbox(alt_messege)
			index = messeges.size()
		else:
			display_current_messege()

		sample_player.play("talk")
		
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
	