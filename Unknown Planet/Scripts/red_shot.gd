extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var velocity = Vector2(-1,0)
var speed = 20
onready var area = get_node("Area2D")
onready var timer = get_node("Timer")
var damage = 1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	area.connect("body_enter", self, "on_red_shot_body_enter")
	timer.connect("timeout", self, "on_redshot_timer_timeout")
	set_process(true)
	
func on_redshot_timer_timeout():
	queue_free()
	
func on_red_shot_body_enter(body):
	if body.is_in_group("player"):
		body.take_damage(self, damage)
	if body.is_in_group("enemy"):
		pass
	else:
		pass
		#queue_free()
	
func _process(delta):
	var motion = velocity*speed*delta
	move(motion)
