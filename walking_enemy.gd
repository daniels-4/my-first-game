extends CharacterBody2D
class_name BigFucker

const SPEED = 75
const TERMINAL_VELOCITY = 500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1 # right

func _physics_process(delta):
	apply_gravity(delta)
	velocity.x = direction * SPEED
	$AnimatedSprite2D.flip_h = true
	move_and_slide()

func apply_gravity(frame):
	if not is_on_floor():
		velocity.y += gravity * frame
		velocity.y = min(velocity.y, TERMINAL_VELOCITY)
