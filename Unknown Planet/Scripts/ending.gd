extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var timer = 0
var delay = 4
var can_go = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	
func _process(delta):
	timer += delta
	if timer > delay:
		can_go = true
	
	if can_go and Input.is_action_pressed("fire"):
		get_tree().quit()
