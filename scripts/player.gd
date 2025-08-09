extends CharacterBody2D

	
const SPEED = 100.0
const JUMP_VELOCITY = -320.0
const JUMP_BUFFER_TIME = .1
const JUMP_WALKOFF_TIME = .1
const DASH_SPEED = 500
const DASH_TIMER = .1
const DASH_BUFFER_TIME = .1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var audio_jump: AudioStreamPlayer2D = $AudioStreamPlayer2D

var jump_buffer = false
var jump_available = true
var on_floor = false
var on_wall = true
var wall_left_used = false
var wall_right_used = false
var second_jump = false
var dash_active = false
var dash_available = false
var dash_direction = false
var dash_buffer = false

@export var double_jump = false
@export var wall_jump = false
@export var dash = false
@export var gravity_switch = false
@export var gravity = 1


func _physics_process(delta: float) -> void:
	animated_sprite.flip_v = gravity == -1
	
	if gravity == 1:
		animated_sprite.position.y = -12
		animated_sprite.flip_h = false
	else:
		animated_sprite.position.y = -3
		animated_sprite.flip_h = true
	
	if wall_jump:
		if is_on_wall():
			if ray_cast_left.is_colliding() and not wall_left_used:
				velocity.y = 25
				wall_left_used = true
				wall_right_used = false
				on_wall = true
				jump_available = true
			if ray_cast_right.is_colliding() and not wall_right_used:
				velocity.y = 25
				wall_right_used = true
				wall_left_used = false
				on_wall = true
				jump_available = true
		elif on_wall:
			on_wall = false
			get_tree().create_timer(JUMP_WALKOFF_TIME).timeout.connect(jump_walkoff_timeout)
	
	if is_on_ground():
		if dash and not dash_active:
			dash_available = true
		if double_jump:
			second_jump = true
		wall_left_used = false
		wall_right_used = false
		jump_available = true
		on_floor = true
	
	# Add the gravity.
	if not is_on_ground() and not on_wall:
		if not dash_active:
			velocity += get_gravity() * delta * gravity
		if on_floor:
			get_tree().create_timer(JUMP_WALKOFF_TIME).timeout.connect(jump_walkoff_timeout)
			on_floor = false

	
	if is_on_ground() and jump_buffer:
		jump()
		


	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if jump_available and not dash_active:
			jump()
		elif second_jump:
			jump()
			second_jump = false
		else:
			jump_buffer = true
			get_tree().create_timer(JUMP_BUFFER_TIME).timeout.connect(jump_buffer_timeout)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction and not dash_active:
		velocity.x = direction * SPEED
		if direction > 0:
			animated_sprite.play("running")
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.play("running")
			animated_sprite.flip_h = true
	elif not dash_active:
		animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("special") and gravity_switch:
		gravity = -gravity
	
	if (Input.is_action_just_pressed("special") or (dash_buffer and is_on_ground())) and dash_available:
		dash_buffer = false
		dash_available = false
		velocity.y = 0
		dash_active = true
		dash_direction = animated_sprite.flip_h
		get_tree().create_timer(DASH_TIMER).timeout.connect(dash_timeout)
	
	if Input.is_action_just_pressed("special") and not dash_available:
		dash_buffer = true
		get_tree().create_timer(DASH_BUFFER_TIME).timeout.connect(dash_buffer_timeout)
	
	if dash_active:
		animated_sprite.play("dash")
		if not dash_direction:
			velocity.x = DASH_SPEED
			animated_sprite.flip_h = false
		elif dash_direction:
			velocity.x = -DASH_SPEED
			animated_sprite.flip_h = true
	
	move_and_slide()

func jump() -> void:
	audio_jump.play()
	velocity.y = JUMP_VELOCITY * gravity
	on_wall = false
	jump_buffer = false
	jump_available = false
	
func jump_buffer_timeout() -> void:
	jump_buffer = false

func jump_walkoff_timeout() -> void:
	if not on_wall:
		jump_available = false
		
func dash_timeout() -> void:
	dash_active = false
	
func dash_buffer_timeout() -> void:
	dash_buffer = false

func is_on_ground() -> bool:
	if gravity == 1:
		return is_on_floor()
	else:
		return is_on_ceiling()
