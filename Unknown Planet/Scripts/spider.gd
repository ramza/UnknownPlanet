extends KinematicBody2D

var explosion = preload("res://Scenes/small_explosion.tscn")
var coin = preload("res://Scenes/coin.tscn")
var ammo = preload("res://Scenes/ammopack.tscn")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var STATES = {
	"IDLE":0,
	"DOWN":1,
	"UP":2,
}

var x_offset = 24
var y_offset = 0
var state
var hp = 1
onready var sprite = get_node("Sprite")
onready var timer = get_node("Timer")
onready var sample_player = get_node("SamplePlayer2D")
onready var raycast_down = get_node("RayCast2D")

var velocity = Vector2(0,0)
var speed = 10
var damage = 1
var start_pos

func death():
	var e = explosion.instance()
	game_manager.current_scene.add_child(e)
	e.set_global_pos(get_global_pos())
	
	var r = rand_range(0,10)
	if r < 3:
		drop_item(coin)
	elif r < 5:
		drop_item(ammo)
	
	
	queue_free()

func take_damage(dmg):
	hp -= dmg 

	if hp <= 0:
		death()
		timer.start()

func drop_item(item):
	var i = item.instance()
	i.set_global_pos(get_global_pos())
	game_manager.current_scene.add_child(i)

func contact():
	pass
	
func disable():
	pass

func _ready():
	
	state = STATES.IDLE
	# Called every time the node is added to the scene.
	# Initialization here
	timer.connect("timeout", self, "on_spider_timer_timeout")
	start_pos = get_global_pos()
	set_process(true)
	
func on_spider_timer_timeout():
	death()
	
func _process(delta):
	if raycast_down.is_colliding() and raycast_down.get_collider() != null and raycast_down.get_collider().is_in_group("player"):
		state= STATES.DOWN
	
	var force = Vector2(0,0)
	
	if state == STATES.DOWN:
		force.y += speed
	elif state == STATES.IDLE:
		velocity.y = 0
	elif state == STATES.UP:
		force.y -= speed
	
	velocity += force * delta
	move(velocity)
	
	if is_colliding():
		if velocity.y > 0:
			state=STATES.UP
		elif velocity.y < 0 and get_collider() != null and !get_collider().is_in_group("player"):
			state=STATES.IDLE
