extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var gravity = 50.0
var thrust = 300
var velocity = Vector2(0,0)

var pickup_type = "ammo"
var amount = 3
onready var raycast = get_node("RayCast2D")
onready var area = get_node("Area2D")
onready var sample_player = get_node("SamplePlayer2D")
onready var timer = get_node("Timer")
onready var sprite = get_node("Sprite")
var active = true

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	setup()

	
func setup():
	timer.connect("timeout", self, "on_pickup_timer_timeout")
	area.connect("body_enter", self, "on_ammo_pickup_body_enter")
	
	
func on_pickup_timer_timeout():
	queue_free()
	
func do_fx(player):
	player.add_ammo(amount)
	sample_player.play("fx")
	sprite.hide()

func on_ammo_pickup_body_enter(body):
	if active and body.is_in_group("player"):
		active = false
		do_fx(body)
		timer.start()

func _fixed_process(delta):
	
	var force = Vector2(0, gravity)
	
	if raycast.is_colliding():
		force.y -= thrust
		
	velocity += force * delta
	var motion = velocity * delta
	move(motion)
