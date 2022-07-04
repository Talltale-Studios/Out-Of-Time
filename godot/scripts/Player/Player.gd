extends KinematicBody2D


enum States {IDLE, RUN, JUMP, FALL, HARD_LAND, DASH, ATTACK}


export var attack_damage : int
export var health : int = 30
export var speed : float = 100
export var jump_strength : float = 290
export var maximum_jumps : float = 1
export var double_jump_strength : float = 125
export var gravity : float = 600
export var init_colors : PoolColorArray
export var hard_fall_limit : float = -1


var up_direction = Vector2.UP
var _jumps_made : int = 0
var _max_jumps : int = 1
var _velocity : Vector2 = Vector2.ZERO
var score := 0
var state
var jump_held := false
var jump_origin = Vector2(0,0)
var last_velocity = 0
var jump_new_origin = Vector2(0,0)
var can_fall = true
var can_move = true
var fall_distance


onready var trail : Particles2D = $Particles2D
onready var animator = $PlayerSprite
onready var ground_detector = $GroundDetector


func _physics_process(delta : float):
	var left = Input.get_action_strength("left")
	var right = Input.get_action_strength("right")
	var horizontal_direction = (right - left)
	
	if can_move:
		_velocity.x = horizontal_direction * speed
	else:
		_velocity.x = 0
	_velocity.y += gravity * delta
	
	if is_on_floor():
		jump_new_origin = position
		fall_distance = jump_origin - jump_new_origin
		if fall_distance.y <= hard_fall_limit:
			can_move = false
			state = States.HARD_LAND
		can_fall = true
	else:
		match can_fall:
			true:
				can_fall = false
				jump_origin = position
	
	if ground_detector.is_colliding():
		last_velocity = _velocity.y
	
	match state:
		States.IDLE:
			animator.play("idle")
		States.RUN:
			animator.play("run")
		States.JUMP:
			animator.play("jump")
		States.FALL:
			animator.play("fall")
		States.HARD_LAND:
			animator.play("hard_land")
		States.DASH:
			animator.play("dash")
	
	_velocity = move_and_slide(_velocity, up_direction)
	
	var is_falling = _velocity.y > 0.0 and not is_on_floor()
	var is_jumping = Input.is_action_just_pressed("jump") and is_on_floor()
	var is_double_jumping = Input.is_action_just_pressed("jump") and is_falling
	var is_jump_cancelled = Input.is_action_just_released("jump") and _velocity.y < 0.0
	var is_idling = is_on_floor() and is_zero_approx(_velocity.x)
	var is_running = is_on_floor() and not is_zero_approx(_velocity.x)
	
	if can_move:
		if is_jumping:
			_velocity.y = -jump_strength
		elif is_double_jumping:
			_jumps_made += 1
			if _jumps_made < maximum_jumps:
				_velocity.y = -jump_strength
		elif is_jump_cancelled:
			jump_held = false
			_velocity.y = 0
			pass
		elif is_idling or is_running:
			_jumps_made = 0
	
	if health > 0:
		if state != States.HARD_LAND:
			if left:
				$PlayerSprite.scale.x = -1
			if right:
				$PlayerSprite.scale.x = 1
			if is_running:
				state = States.RUN
			if is_idling:
					state = States.IDLE
			if is_jumping and not is_falling:
				state = States.JUMP
			if is_falling:
				state = States.FALL


func _on_PlayerSprite_animation_finished():
	match state:
		States.HARD_LAND:
			state = States.IDLE
			can_move = true
			can_fall = true
			jump_new_origin = position
			jump_origin = position
