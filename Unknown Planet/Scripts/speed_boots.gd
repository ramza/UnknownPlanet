extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var timer = get_node("Timer")
onready var sound = get_node("SamplePlayer2D")
onready var sprite = get_node("Sprite")
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	timer.connect("timeout", self, "on_speed_boots_timer_timeout")
	connect("body_enter", self, "on_speed_boots_body_enter")

func on_speed_boots_timer_timeout():
	queue_free()
	
func on_speed_boots_body_enter(body):
	if body.is_in_group("player"):
		timer.start()
		sprite.hide()
		sound.play("powerup")
		game_manager.speed_boots = true
		game_manager.player.speed_bonus = 1.2
		game_manager.HUD.update_cards()