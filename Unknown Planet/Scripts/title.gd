extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	OS.set_window_maximized(true)
	set_process(true)
	
func _process(delta):
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("start"):
		game_manager.goto_scene("res://Scenes/"+game_manager.scenes[1]+".tscn")
		
		