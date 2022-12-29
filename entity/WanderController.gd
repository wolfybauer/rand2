extends Node2D

# max +/- distance from start pos
export var wander_range := 32

onready var start_pos = global_position
onready var target_pos = global_position

onready var timer = $Timer

func _ready():
	update_target_pos()

func update_target_pos():
	# get random new point within range from start pos
	var target_vector = Vector2(rand_range(-wander_range,wander_range), rand_range(-wander_range,wander_range))
	target_pos = start_pos + target_vector

func get_time_left():
	return timer.time_left

func start_wander_timer(duration):
	timer.start(duration)
	
func _on_Timer_timeout():
	update_target_pos()
