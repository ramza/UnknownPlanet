extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var damage = 1
onready var anim = get_node("Sprite").get_node("AnimationPlayer")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("body_enter", self, "on_enemy_attack_body_enter")
	anim.connect("finished", self, "on_enemy_anim_finished")

func on_enemy_anim_finished():
	queue_free()

func on_enemy_attack_body_enter(body):
	if body.is_in_group("player"):
		body.take_damage(body, damage)