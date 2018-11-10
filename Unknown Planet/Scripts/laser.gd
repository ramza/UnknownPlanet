extends KinematicBody2D

var burst = preload("res://Scenes/player_laser_burst.tscn")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var velocity = Vector2(1,0)
var speed = 300
var dmg = 1

onready var area = get_node("Area2D")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	area.connect("body_enter", self, "on_laser_body_enter")
	set_fixed_process(true)
	
func on_laser_body_enter(body):
	var b = burst.instance()
	game_manager.current_scene.add_child(b)
	b.set_global_pos(get_global_pos())
	
	if body.is_in_group("enemy"):
		body.take_damage(dmg)
	
	if body.is_in_group("breakable"):
		body.take_damage(dmg)
	
	queue_free()
	
func _fixed_process(delta):
	move(velocity*speed*delta)
		
