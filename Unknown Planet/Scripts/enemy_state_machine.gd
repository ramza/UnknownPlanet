extends Node

onready var anim = get_node("AnimationPlayer")

var STATES = {
	"IDLE":0,
	"WALK":1,
	"HURT":3,
	"JUMP":4,
	"DEAD":5,
	"ATTACK":6,
	"SPELL":7,
}

var state = STATES.IDLE
var prev_state

func do_animation():
	var current_anim = ""
	if state == STATES.IDLE:
		current_anim = "idle"
	elif state == STATES.WALK:
		current_anim = "walk"
	elif state == STATES.JUMP:
		current_anim = "jump"
	elif state == STATES.HURT:
		current_anim = "hurt"
	elif state == STATES.DEAD:
		current_anim = "dead"
	elif state == STATES.ATTACK:
		current_anim = "attack"

	if !anim.is_playing() || state != prev_state:
		anim.play(current_anim)

	prev_state = state
	
func idle():
	state = STATES.IDLE
	
func walk():
	state = STATES.WALK

func hurt():
	state = STATES.HURT
	
func jump():
	state = STATES.JUMP
	
func dead():
	state = STATES.DEAD

func attack():
	state = STATES.ATTACK

func spell():
	state = STATES.SPELL

func on_enemy_state_machine_anim_finished():
	if state == STATES.DEAD:
		queue_free()
	elif state == STATES.ATTACK:
		state == STATES.IDLE

func _ready():
	# Called every time the node is added to the scene.
	anim.connect("finished", self, "on_enemy_state_machine_anim_finished")

