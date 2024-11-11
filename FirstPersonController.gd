extends CharacterBody3D

# This controller uses a few nodes that are mandatory for it to function correctly.
# It has a standing collider and a separate crouching collider that switch off as necessary.
# There is a "CameraPivot" Node3D that is used for mouse look, as well as a upwards facing
# raycast node that is used for seeing if standing is possible.

# Player variables & references.

@export var walking_speed = 5.0
@export var look_sens = 0.25
@onready var camera_pivot = $CameraPivot
@onready var up_cast = $UpCast
@onready var standing_collider = $StandingCollider
@onready var crouching_collider = $CrouchingCollider

var current_sound

# Movement variables.

const JUMP_VELOCITY = 4.5
var current_speed
var direction = Vector3.ZERO
var crouch_speed = walking_speed * 0.5
var sprint_speed = walking_speed * 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * look_sens))
		camera_pivot.rotate_x(deg_to_rad(-event.relative.y * look_sens))
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	# Handles crouching or sprinting.
	if Input.is_action_pressed("Crouch"):

		# Crouching
		if is_on_floor():
			current_speed = crouch_speed # Only adjust the speed if it physically makes sense.
		camera_pivot.position.y = lerp(camera_pivot.position.y, -0.5, delta * 10)

		standing_collider.disabled = true
		crouching_collider.disabled = false

	elif !up_cast.is_colliding():

		# Standing
		camera_pivot.position.y = lerp(camera_pivot.position.y, 0.0, delta * 10)

		standing_collider.disabled = false
		crouching_collider.disabled = true
		
		# Sprinting
		if Input.is_action_pressed("Sprint") and is_on_floor():
			current_speed = sprint_speed
		else:
			current_speed = walking_speed

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * 10) # Smooth transition to movement & stopping via lerp.
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		
	move_and_slide()
