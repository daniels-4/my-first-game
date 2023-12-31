extends CharacterBody2D
class_name Player

enum {
	MOVE_STATE,
	CLIMB_STATE
}

@export var move_data = Resource

var state = MOVE_STATE
var jump_count = 1
var buffered_jump = false
var coyote_buffer = false

@onready var animatedSprite = $AnimatedSprite2D
@onready var ladderCheck = $LadderCheck
@onready var jumpBufferTimer = $JumpBufferTimer
@onready var coyoteJumpTimer = $CoyoteJumpTimer
@onready var remoteTransform2D = $RemoteTransform2D

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
		
	var was_on_floor = is_on_floor()
	move_and_slide()
	var coyote_jump = not is_on_floor() and was_on_floor
	if coyote_jump and velocity.y >= 0:
		coyote_buffer = true
		coyoteJumpTimer.start()
	
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
	
func player_death():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	queue_free()
	events.emit("player_death_event")
	
func input_jump():
	if Input.is_action_just_pressed("ui_accept") or buffered_jump:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = move_data.JUMP_VELOCITY
		buffered_jump = false

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
		jump_count_reset()
	if can_jump():
		input_jump()
	else:
		animatedSprite.animation = "jump"
		if Input.is_action_just_released("ui_accept") and velocity.y < move_data.JUMP_RELEASE_PEAK:
			velocity.y = move_data.JUMP_RELEASE_PEAK
		if Input.is_action_just_pressed("ui_accept") and jump_count > 1:
			SoundPlayer.play_sound(SoundPlayer.JUMP)
			velocity.y = move_data.JUMP_VELOCITY
			jump_count -= 1
		if Input.is_action_just_pressed("ui_accept"):
			buffered_jump = true
			jumpBufferTimer.start()
		if velocity.y > 0:
			velocity.y += move_data.JUMP_RETURN_GRAVITY
			
func face_flip(flip):
	animatedSprite.flip_h = flip

func jump_count_reset():
	jump_count = move_data.JUMP_COUNT

func can_jump():
	return is_on_floor() or coyote_buffer

func _on_jump_buffer_timer_timeout():
	buffered_jump = false

func _on_coyote_jump_timer_timeout():
	coyote_buffer = false

func connect_camera(camera):
	var cameraPath = camera.get_path()
	remoteTransform2D.remote_path = cameraPath
