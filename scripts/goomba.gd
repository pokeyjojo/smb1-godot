extends CharacterBody2D

const SPEED := 52.5
const GRAVITY := 900.0

var direction := 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_floor_left: RayCast2D = $RayCastFloorLeft
@onready var ray_cast_floor_right: RayCast2D = $RayCastFloorRight
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	# --- WALL TURNING ---
	if ray_cast_right.is_colliding():
		direction = -1

	if ray_cast_left.is_colliding():
		direction = 1

	# --- HORIZONTAL MOVEMENT ---
	velocity.x = direction * SPEED

	# --- GRAVITY ---
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0

	# --- PHYSICS MOVEMENT ---
	move_and_slide()
