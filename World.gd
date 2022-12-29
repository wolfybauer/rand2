extends Node2D

export var DEBUG_VISIBLE := true
export var RANDOMIZE := true
export var SEED := 1

var seed_set := 0

onready var player = $YSort/Player
#onready var camera = $YSort/Player/Camera2D
#onready var dbg = $debug_overlay
onready var Hearts = preload("res://HUD/HealthHUD.tscn")

func _ready():
	if DEBUG_VISIBLE:
		var overlay = load("res://HUD/debug_overlay.tscn").instance()
		overlay.add_stat('look',player, 'look_vector', false)
		overlay.add_stat('pos',player, 'position', false)
		overlay.add_stat('node_rot',player, 'node_angle', false)
	#	overlay.add_stat('arm_rot',player, 'arm_angle', false)
		add_child(overlay)
	
	var hearts = Hearts.instance()
	add_child(hearts)

	if RANDOMIZE:
		randomize()
		seed_set = randi()
	else:
		seed_set = SEED
	seed(seed_set)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		print('SEED: ' + str(seed_set))
