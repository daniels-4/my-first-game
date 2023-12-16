extends CharacterBody2D
class_name BigFucker

const SPEED = 25
const TERMINAL_VELOCITY = 500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1 # right

@onready var animatedSprite = $AnimatedSprite2D

func _physics_process(delta):
	var on_wall = is_on_wall()
	if on_wall:
		direction *= -1
	face_flip(direction)
	apply_gravity(delta)
	velocity.x = direction * SPEED
	move_and_slide()

func apply_gravity(frame):
	if not is_on_floor():
		velocity.y += gravity * frame
		velocity.y = min(velocity.y, TERMINAL_VELOCITY)
		
func face_flip(direction):
	if direction > 0:
		animatedSprite.flip_h = true
	else:
		animatedSprite.flip_h = false
