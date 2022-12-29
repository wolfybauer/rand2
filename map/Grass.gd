extends Node2D

onready var my_sprite = $Sprite
const GrassEffect = preload("res://effects/GrassEffect.tscn")

func _process(delta):
	pass
	
func grass_die():
	var grass_effect = GrassEffect.instance()
	grass_effect.global_position = global_position
	grass_effect.offset = my_sprite.offset
	get_parent().add_child(grass_effect)
	queue_free()


func _on_Hurtbox_area_entered(area):
	grass_die()
