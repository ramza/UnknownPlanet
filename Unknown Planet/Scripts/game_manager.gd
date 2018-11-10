extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var player_scene = preload("res://Scenes/player.tscn")
var player

var last_song
var ship_song = preload("res://Audio/Music/dungeon_vibes.ogg")
var caves_song = preload("res://Audio/Music/caves.ogg")
var music_player
var scenes = [
     "landing_zone",
     "ship",
     "caves_1",
     "caves_2",
     "open_area_1",
     "caves_3",
     "base",
     "storeroom",
     "tunnels_1",
     "tunnels_2",
     "tunnels_3",
]
var current_scene_index = 1
var current_scene
var prev_scene
var HUD

var hp_upgrade = false
var gun_upgrade = false
var firerate_upgrade = false

var blue_card = false

var cash_money = 0
var ammo = 25
var health = 3
 
var spawnpoint = 1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	print(current_scene.get_name())
	music_player = global_scene.get_node("StreamPlayer")
	last_song = caves_song
	initialize_scene()

	
func initialize_scene():
	HUD = current_scene.get_node("HUD")
	player = player_scene.instance()
	player.set_global_pos(current_scene.get_node("SpawnPoint"+str(spawnpoint)).get_global_pos())
	player.get_node("LaserGun").ammo = ammo
	if hp_upgrade:
		player.max_hp += 1
	if gun_upgrade:
		player.get_node("LaserGun").energy_replenish_delay = 1.0
	if firerate_upgrade:
		player.get_node("LaserGun").firerate = 0.15
		
	current_scene.add_child(player)
	if ( spawnpoint % 2 == 0):
		player.flip()
		
func handle_music():
	if current_scene_index == 1:
		music_player.set_stream(ship_song)
		music_player.play()
	elif current_scene_index == 0:
		music_player.set_stream(caves_song)
		music_player.play()

func save_player_stats():
	ammo = player.get_node("LaserGun").ammo
	health = player.hp
	
func goto_scene(path):
    # This function will usually be called from a signal callback,
    # or some other function from the running scene.
    # Deleting the current scene at this point might be
    # a bad idea, because it may be inside of a callback or function of it.
    # The worst case will be a crash or unexpected behavior.

    # The way around this is deferring the load to a later time, when
    # it is ensured that no code from the current scene is running:

    call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
    # Immediately free the current scene,
    # there is no risk here.
    prev_scene = current_scene
    current_scene.free()

    # Load new scene.
    var s = ResourceLoader.load(path)

    # Instance the new scene.
    current_scene = s.instance()

    # Add it to the active scene, as child of root.
    get_tree().get_root().add_child(current_scene)

    # Optional, to make it compatible with the SceneTree.change_scene() API.
    get_tree().set_current_scene(current_scene)

    initialize_scene()

