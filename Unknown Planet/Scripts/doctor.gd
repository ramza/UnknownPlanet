extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var doc1
var doc2

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	game_manager.game_over = false
	doc1 = get_node("Doctor1")
	doc2 = get_node("Doctor2")
	if game_manager.blue_card:
		doc1.queue_free()
	else:
		doc2.queue_free()
