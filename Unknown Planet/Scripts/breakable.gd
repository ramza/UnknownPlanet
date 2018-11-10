extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var hp = 3

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func take_damage(dmg):
	hp -= dmg
	if hp <= 0:
		queue_free()
