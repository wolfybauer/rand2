extends CanvasLayer

var hearts = 6 setget set_hearts
var max_hearts = 6 setget set_max_hearts

onready var bone = $Bone
onready var bone_broken = $BoneBroken

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if bone != null && bone_broken != null:
		bone.rect_size.x = hearts * 16
		bone_broken.rect_size.x = (max_hearts - hearts) * 16
		if hearts == max_hearts:
			bone_broken.visible = false
		elif hearts == 0:
			bone.visible = false
		else:
			bone.visible = true
			bone_broken.visible = true

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = max(value, 1)
	if bone != null and bone_broken != null:
		bone.rect_size.x = value * 16
		bone_broken.rect_position.x = value * 16
		bone_broken.visible = false

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
