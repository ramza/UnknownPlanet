extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var rain = preload("res://Scenes/rain.tscn")

func _ready():
	
	# Called every time the node is added to the scene.
	# Initialization here
	randomize()
	var rand = rand_range(1,100)
	print(rand)
	if (rand < 30):
		var r = rain.instance()
		game_manager.camera.add_child(r)
