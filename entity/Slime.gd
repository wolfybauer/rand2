extends KinematicBody2D

# exports
export var KNOCKBACK = 200
export var ACCELERATION = 100
export var MAX_SPEED = 40
export var FRICTION = 600
export var GOTO_CUTOFF = 6
export var COLLIDE_PUSH = 500

# preloads
const SlimeDeath = preload("res://effects/SlimeDeath.tscn")

# state stuff
enum STATE {
	IDLE,
	WANDER,
	CHASE,
}
var slime_state = STATE.IDLE
onready var wander_controller = $WanderController

# movement stuff
var knockback = Vector2.ZERO
var velocity = Vector2.ZERO


# stats
onready var stats = $Stats
onready var player_detect = $PlayerDetectZone
onready var slime_sprite = $AnimatedSprite

# hithurt
onready var hurt_box = $Hurtbox
onready var soft_collision = $SoftCollision

func _ready():
	slime_state = choose_state([STATE.IDLE, STATE.WANDER])

func _process(_delta):
	pass

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match slime_state:
		STATE.IDLE:
			slime_sprite.play("idle")
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			update_wander()
		STATE.WANDER:
			slime_sprite.play("move")
			seek_player()
			update_wander()
			go_to(wander_controller.target_pos, delta)
			if global_position.distance_to(wander_controller.target_pos) <= GOTO_CUTOFF:
				slime_state = choose_state([STATE.IDLE, STATE.WANDER])
		STATE.CHASE:
			slime_sprite.play("move")
			var player = player_detect.player
			if player != null:
#				var dir = (player.global_position - global_position).normalized()
				go_to(player.global_position, delta)
			else:
				slime_state = STATE.IDLE
	
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * COLLIDE_PUSH
	velocity = move_and_slide(velocity)

func go_to(pos, delta):
	var dir = global_position.direction_to(pos)
	velocity = velocity.move_toward(dir * MAX_SPEED, ACCELERATION * delta)
	slime_sprite.flip_h = velocity.x > 0

func update_wander():
	if wander_controller.get_time_left() == 0:
		slime_state = choose_state([STATE.IDLE, STATE.WANDER])
		wander_controller.start_wander_timer(rand_range(1,3))

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK
	hurt_box.start_invincible(0.5)
	hurt_box.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var death = SlimeDeath.instance()
	death.global_position = global_position
	death.offset = $AnimatedSprite.offset
	get_parent().add_child(death)


func seek_player():
	if player_detect.can_see_player():
		slime_state = STATE.CHASE

func choose_state(state_list:Array):
	state_list.shuffle()
	return state_list.pop_front()
	
func _on_Hurtbox_area_exited(area):
	pass
