extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var anim = get_node("AnimationPlayer")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	anim.connect("finished", self, "on_dust_anim_finished")

func on_dust_anim_finished():
	queue_free()