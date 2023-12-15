extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const TERMINAL_VELOCITY = 700
@export var JUMP_RELEASE_PEAK: int = -150.0
@export var JUMP_RETURN_GRAVITY: int = 5.0

@onready var animatedSprite = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	animatedSprite.frames = load("res://PlayerSandSkin.tres")
	
func _physics_process(delta):
	apply_gravity(delta)
	jump_handler()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		animatedSprite.animation = "run"
		if direction > 0:
			player_face_flip(true)
		if direction < 0:
			player_face_flip(false)
		else:
			pass
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animatedSprite.animation = "idle"

	move_and_slide()
	
func apply_gravity(frame):
	if not is_on_floor():
		velocity.y += gravity * frame
		velocity.y = min(velocity.y, TERMINAL_VELOCITY)
		
func jump_handler():
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
	else:
		animatedSprite.animation = "jump"
		if Input.is_action_just_released("ui_accept") and velocity.y < JUMP_RELEASE_PEAK:
			velocity.y = JUMP_RELEASE_PEAK
		if velocity.y > 0:
			velocity.y += JUMP_RETURN_GRAVITY
			
func player_face_flip(flip):
	animatedSprite.flip_h = flip
