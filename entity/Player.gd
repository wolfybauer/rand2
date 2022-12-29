extends KinematicBody2D

# enums
enum WEAPON {
	SAWEDOFF,
	TWOSHOOT,
}
enum STATE {
	IDLE,
	MOVE,
	SMACK,
	ROLL,
	SHOOT,
	JUMP,
	RELOAD,
}

# weapon sprites
onready var twoshoot_tex = preload("res://art/2shoot_ex.png")
onready var sawedoff_tex = preload("res://art/sawedoff_ex.png")


# movement characteristics
export var ACCELERATION = 300
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 400
export var SMACK_SLOWDOWN = 0.9
var velocity = Vector2.ZERO
var deadzone = 0.2
var node_angle

# state machine bools
var aim_enable := true
var change_enable := true

# input direction vectors
var move_vector = Vector2.ZERO
var look_vector = Vector2.ZERO
var roll_vector = Vector2.RIGHT

# animators
onready var anim_player = $AnimationPlayer
onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get('parameters/playback')

# rotator stuff
onready var body_sprite = $BodySprite
onready var arm_sprite = $ArmNode/ArmSprite
onready var arm_node = $ArmNode

# hit/hut
onready var smack_box = $ArmNode/SmackBox
onready var hurt_box = $Hurtbox

# player init state
var player_state = STATE.MOVE
var player_weapon = WEAPON.SAWEDOFF

# player stats
var stats = PlayerStats

func move():
	velocity = move_and_slide(velocity)

func move_player(delta):
	move_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	move_vector = move_vector.normalized()
	
	if move_vector:
		velocity = velocity.move_toward(move_vector * MAX_SPEED, ACCELERATION * delta)
		anim_state.travel("move")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		anim_state.travel('idle')
	move()

func aim_player():
	if aim_enable:
		look_vector.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
		look_vector.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
		look_vector = look_vector.normalized()
	else:
		look_vector = Vector2.ZERO
	node_angle = look_vector.angle()
	
	if look_vector:
		if look_vector.x < 0:
			body_sprite.flip_h = true
			arm_sprite.flip_h = true
			arm_sprite.offset = Vector2(-2,0)
			arm_node.position = Vector2(2,-7)
			arm_sprite.rotation = PI
		else:
			body_sprite.flip_h = false
			arm_sprite.flip_h= false
			arm_sprite.offset = Vector2(2,0)
			arm_node.position = Vector2(-2,-7)
			arm_sprite.rotation = 0
		arm_node.rotation = node_angle
		smack_box.knockback_vector = look_vector
	else:
		if move_vector:
			if move_vector.x < 0:
				body_sprite.flip_h = true
				arm_sprite.flip_h = true
				arm_sprite.offset = Vector2(-2,0)
				arm_node.position = Vector2(2,-7)
				arm_sprite.rotation = PI
			else:
				body_sprite.flip_h = false
				arm_sprite.flip_h= false
				arm_sprite.offset = Vector2(2,0)
				arm_node.position = Vector2(-2,-7)
				arm_sprite.rotation = 0
			arm_node.rotation = move_vector.angle()
			look_vector = move_vector
			smack_box.knockback_vector = move_vector
	roll_vector = look_vector
	
	


func change_weapon():
	if change_enable:
		player_weapon = (player_weapon + 1) % len(WEAPON)
		match player_weapon:
			WEAPON.SAWEDOFF:
				arm_sprite.texture = sawedoff_tex
			WEAPON.TWOSHOOT:
				arm_sprite.texture = twoshoot_tex

func smack(delta):
	move_player(delta)
#	velocity *= 0.2
	velocity = velocity.linear_interpolate(Vector2.ZERO, SMACK_SLOWDOWN)
	change_enable = false
	anim_state.travel('smack')
	move()
func smack_done():
	change_enable = true
	player_state = STATE.MOVE

func roll(delta):
	anim_state.travel('roll')
	velocity = roll_vector * ROLL_SPEED
	move()
func roll_done():
	velocity *= 0.4
	player_state = STATE.MOVE

func shoot():
	pass

func _ready():
	anim_tree.active = true
	
	# connect stats signal
	stats.connect("no_health", self, "queue_free")
	print(stats.max_health)

func _physics_process(delta):
	match player_state:
		STATE.MOVE:
			move_player(delta)
			aim_player()
		STATE.SMACK:
			smack(delta)
		STATE.ROLL:
			roll(delta)

func _unhandled_input(event):
	if event.is_action_pressed("change_weapon"):
		change_weapon()
	if event.is_action_pressed("shoot"):
#		player_state = STATE.SHOOT
		pass
	if event.is_action_pressed("smack"):
		player_state = STATE.SMACK
	if event.is_action_pressed("roll"):
		if move_vector:
			player_state = STATE.ROLL
	if event.is_action_pressed("jump"):
		pass


func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	hurt_box.start_invincible(0.5)
	hurt_box.create_hit_effect()
