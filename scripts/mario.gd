extends CharacterBody2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# --------- CONSTANTS (tweak these to taste) ---------
# Speeds (approx SMB1 feel; walk slower, run faster)
const WALK_SPEED: float = 80.0
const RUN_SPEED: float = 180.0

# Acceleration / deceleration
const ACCEL_GROUND: float = 450.0      # slower accel than before
const ACCEL_AIR: float = 250.0         # less control in air
const DECEL_GROUND: float = 900.0      # how fast you stop when letting go
const SKID_DECEL: float = 1400.0       # strong decel only when reversing

# Jump tuning
const JUMP_VELOCITY: float = -350.0    # higher jump than -300
const JUMP_CUT_MULTIPLIER: float = 0.5 # let go of jump = shorter hop

# Death arc
const DEATH_JUMP_VELOCITY: float = -350.0

var dead: bool = false

func die() -> void:
	if dead:
		return
	
	dead = true
	# Upward "death" pop
	velocity = Vector2.ZERO
	velocity.y = DEATH_JUMP_VELOCITY
	
	# Disable collision so he falls through things, but still moves
	$CollisionShape2D.queue_free()
	
	animated_sprite.play("death")
	# (Keep your existing audio setup – not touching sounds here)

func _physics_process(delta: float) -> void:
	var gravity: Vector2 = get_gravity()
	
	# ---------- DEATH PHYSICS ----------
	if dead:
		# Just fall with gravity, no input
		velocity += gravity * delta
		move_and_slide()
		return
	
	# ---------- GRAVITY ----------
	if not is_on_floor():
		velocity += gravity * delta

	# ---------- INPUT ----------
	var direction: float = Input.get_axis("move_left", "move_right")  # -1, 0, 1
	# Hold "run" to use RUN_SPEED. You’ll need an Input action named "run".
	var is_running: bool = Input.is_action_pressed("run")
	var target_speed: float = 0.0
	if direction != 0.0:
		target_speed = (RUN_SPEED if is_running else WALK_SPEED) * direction

	# ---------- JUMP ----------
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		audio_stream_player_2d.play()  # keep your jump sound

	# Jump cut: if you let go of jump early, shorten the jump (more NES-like)
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	# ---------- HORIZONTAL MOVEMENT ----------
	if direction != 0.0:
		# Flip sprite
		if direction > 0.0:
			animated_sprite.flip_h = false
		elif direction < 0.0:
			animated_sprite.flip_h = true
		
		# Are we reversing direction while moving fast? -> brief skid
		if sign(velocity.x) != sign(direction) and abs(velocity.x) > 40.0:
			var decel: float = SKID_DECEL if is_on_floor() else ACCEL_AIR
			velocity.x = move_toward(velocity.x, target_speed, decel * delta)
		else:
			# Normal acceleration
			var accel: float = ACCEL_GROUND if is_on_floor() else ACCEL_AIR
			velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	else:
		# No input: decelerate to 0 (no ice feeling)
		var decel: float = DECEL_GROUND if is_on_floor() else ACCEL_AIR
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)

	# ---------- ANIMATIONS ----------
	if is_on_floor():
		if abs(velocity.x) < 5.0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Animation speed scales a bit with horizontal speed
	var speed_ratio: float = abs(velocity.x) / RUN_SPEED
	speed_ratio = clamp(speed_ratio, 0.0, 1.0)
	animated_sprite.speed_scale = 0.8 + 0.6 * speed_ratio

	# ---------- MOVE ----------
	move_and_slide()
