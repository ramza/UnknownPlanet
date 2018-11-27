extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var velocity = Vector2(-1,0)
var speed = 100
onready var area = get_node("Area2D")

var timer = 0
var death_delay = 1
var dead = false

var damage = 1
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	velocity.y = rand_range(-0.5,0.5)
	area.connect("body_enter", self, "on_fireball_body_enter")
	set_process(true)
	
func on_fireball_body_enter(body):
	if body.is_in_group("player"):
		body.take_damage(self, damage)
	dead = true
	
func _process(delta):
	if dead:
		timer += delta
		if timer > death_delay:
			queue_free()
	var motion = velocity*speed*delta
	move(motion)
