extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var rain = preload("res://Scenes/rain.tscn")
var timer = 0
var delay = 0.1
var can_rain = true

func _ready():
	
	# Called every time the node is added to the scene.
	# Initialization here
	
	set_process(true)
	
func _process(delta):
	timer += delta
	if can_rain and timer > delay:
		can_rain = false
		make_rain()
		
func make_rain():
	randomize()
	var rand = rand_range(1,100)
	if (rand < 50):
		print("rain")
		var r = rain.instance()
		game_manager.camera.add_child(r)
