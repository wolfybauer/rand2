extends Area2D

const SmackEffect = preload("res://effects/SmackEffect.tscn")

var invincible = false setget set_invincible
var layer_buf = 0

onready var timer = $Timer

signal invincible_started
signal invincible_ended

# callable from outside node
func set_invincible(value:bool):
	invincible = value
	if self.invincible == true:
		emit_signal("invincible_started")
	else:
		emit_signal("invincible_ended")

func start_invincible(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var effect = SmackEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position


func _on_Timer_timeout():
	# must call with self for setter to activate
	self.invincible = false

# disables all collision layers by setting bitmask to 0
# buffers layers, restores upon invincible ended
func _on_Hurtbox_invincible_started():
	layer_buf = self.collision_layer
	self.collision_layer = 0

func _on_Hurtbox_invincible_ended():
	self.collision_layer = layer_buf
