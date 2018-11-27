extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var hp = 3
onready var audio = get_node("SamplePlayer2D")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func take_damage(dmg):
	hp -= dmg
	audio.play("crack")
	if hp <= 0:
		queue_free()
