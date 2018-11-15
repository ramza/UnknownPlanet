extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var splash = preload("res://Scenes/small_explosion.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("body_enter", self, "on_water_body_enter")

func on_water_body_enter(body):
	if body.is_in_group("player"):
		body.take_damage(self,100)
		var e = splash.instance()
		e.set_pos(get_pos())
		game_manager.current_scene.add_child(e)