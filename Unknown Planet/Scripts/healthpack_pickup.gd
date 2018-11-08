extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var gravity = 50.0
var thrust = 300
var velocity = Vector2(0,0)

var pickup_type = "health"
var amount = 1
onready var raycast = get_node("RayCast2D")
onready var area = get_node("Area2D")
onready var sample_player = get_node("SamplePlayer2D")
onready var timer = get_node("Timer")
onready var sprite = get_node("Sprite")
var active = true

var max_height
var min_height

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	max_height = get_pos().y - 100
	min_height = get_pos().y + 20
	setup()

	
func setup():
	timer.connect("timeout", self, "on_pickup_timer_timeout")
	area.connect("body_enter", self, "on_health_pickup_body_enter")
	
func do_fx(player):
	player.add_health(amount)
	sample_player.play("fx")
	
func on_pickup_timer_timeout():
	queue_free()

func on_health_pickup_body_enter(body):
	if active and body.is_in_group("player"):
		do_fx(body)
		active = false
		sprite.hide()
		sample_player.play("fx")
		timer.start()

func _fixed_process(delta):
	
	var force = Vector2(0, gravity)
		
	if raycast.is_colliding():
		force.y -= thrust
		
	velocity += force * delta
	var motion = velocity * delta
	move(motion)
