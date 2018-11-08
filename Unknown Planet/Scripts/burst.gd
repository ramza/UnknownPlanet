extends Particles2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var timer = get_node("Timer")

func on_burst_timer_timeout():
	queue_free()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	timer.connect("timeout", self, "on_burst_timer_timeout")
