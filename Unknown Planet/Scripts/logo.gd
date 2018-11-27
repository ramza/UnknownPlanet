extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var timer = get_node("Timer")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	OS.set_window_maximized(true)
	timer.connect("timeout", self, "on_logo_timer_timeout")
	
func on_logo_timer_timeout():
	game_manager.goto_scene("res://Scenes/"+game_manager.scenes[23]+".tscn")
		

