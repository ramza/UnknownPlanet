extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var timer = get_node("Timer")
var can_continue = true

var finished = false

export var messeges = []

var index = 0
var player

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	timer.connect("timeout", self, "on_character_dialogue_timer_timeout")

func on_character_dialogue_timer_timeout():
	game_manager.goto_scene("res://Scenes/"+game_manager.scenes[1]+".tscn")
		

		
func display_current_messege():
	game_manager.HUD.update_textbox(messeges[index])
	index+=1
		
func _process(delta):
	if can_continue and (Input.is_action_pressed("ui_accept")):
		if index > messeges.size()-1:
			set_process(false)
			index = 0
			game_manager.HUD.hide_textbox()
			finished = true
			
		else:
			can_continue = false
			display_current_messege()
			
		timer.start()
	