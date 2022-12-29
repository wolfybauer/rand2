extends Area2D

var player = null

func can_see_player():
	return player != null

# set via collision mask layers
func _on_PlayerDetectZone_body_entered(body):
	player = body


func _on_PlayerDetectZone_body_exited(body):
	player = null
