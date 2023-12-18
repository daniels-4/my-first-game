extends CharacterBody2D
class_name Player

enum {
	MOVE_STATE,
	CLIMB_STATE
}

@export var move_data = Resource

var state = MOVE_STATE

@onready var animatedSprite = $AnimatedSprite2D
@onready var ladderCheck = $LadderCheck

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	animatedSprite.frames = load("res://player_sand_skin.tres")
	
func _physics_process(delta):
	match state:
		MOVE_STATE: move_state(delta)
		CLIMB_STATE: climb_state()

func reset_check():
	if Input.is_action_just_pressed("level_reset"):
		get_tree().reload_current_scene()
	
func move_state(delta):
	reset_check()
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB_STATE
	apply_gravity(delta)
	jump_handler()
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * move_data.SPEED
		animatedSprite.animation = "run"
		if direction > 0:
			face_flip(true)
		if direction < 0:
			face_flip(false)
		else:
			pass
	else:
		velocity.x = move_toward(velocity.x, 0, move_data.SPEED)
		animatedSprite.animation = "idle"

	move_and_slide()
	
func climb_state():
	reset_check()
	if not is_on_ladder():
		state = MOVE_STATE
	var direction = Input.get_axis("ui_up", "ui_down")
	if direction != 0:
		animatedSprite.animation = "run"
	else:
		animatedSprite.animation = "idle"
	velocity.y = direction * move_data.CLIMB_SPEED
	move_and_slide()
	
func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var valid_ladder = ladderCheck.get_collider()
	if not valid_ladder is Ladder: return false
	return true
	
func apply_gravity(frame):
	if not is_on_floor():
		velocity.y += gravity * frame
		velocity.y = min(velocity.y, move_data.TERMINAL_VELOCITY)
		
func jump_handler():
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = move_data.JUMP_VELOCITY
	else:
		animatedSprite.animation = "jump"
		if Input.is_action_just_released("ui_accept") and velocity.y < move_data.JUMP_RELEASE_PEAK:
			velocity.y = move_data.JUMP_RELEASE_PEAK
		if velocity.y > 0:
			velocity.y += move_data.JUMP_RETURN_GRAVITY
			
func face_flip(flip):
	animatedSprite.flip_h = flip
