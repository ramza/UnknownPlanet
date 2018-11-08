extends Timer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var sample_player = get_node("SamplePlayer2D")

var steps_on = false


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.start()
	connect("timeout", self, "on_steps_timer_timeout")
	
func on_steps_timer_timeout():
	if steps_on:
		sample_player.voice_set_pitch_scale(1,rand_range(0.5,1))
		sample_player.play("steps")

func play_landing_sound():
	sample_player.play("land")
	
func play_jump_sound():
	sample_player.voice_set_pitch_scale(1,1)
	sample_player.play("jump")
	
func play_death_sound():
	sample_player.voice_set_pitch_scale(1,1)
	sample_player.play("death")
	
	
func play_hurt_sound():
	sample_player.voice_set_pitch_scale(1,1)
	sample_player.play("hurt")
	
