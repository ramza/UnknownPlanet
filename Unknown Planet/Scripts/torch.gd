extends Light2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var min_light = 0.7
export var max_light = 1.3
var flicker

onready var timer = get_node("Timer")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	flicker = rand_range(min_light, max_light)
	timer.start()
	timer.connect("timeout", self, "on_torch_timer_timeout")
	
func on_torch_timer_timeout():
	flicker = rand_range(min_light, max_light)
	self.set_energy(flicker)
