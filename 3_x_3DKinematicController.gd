extends KinematicBody # "What type of node is this script attached to"
signal shoot_attempt # Custom signal declaration

# Variables we can adjust in the inspector
export(float) var move_speed = 30.0
export(float) var jump_strength = 2.0
export(float) var mouseSens = .5

# Get project's gravity setting
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Stuff for limiting the up/down rotation of the camera
var minLookAngle = -90
var maxLookAngle = 90

# Declare some private vectors we'll use later
var mousePosition = Vector2()
var playerVelocity = Vector3()
var localDir = Vector3()

# Find the camera
onready var camera = get_node("Camera")

# What even are finite state machines
var jumpingState

# Lock the mouse to the center of the screen and make it invisible
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Handles calling functions for movement & mouse aim
func _process(delta):
	PlayerInputs(delta)
	_input(delta)
	
# Handles things like applying gravity and actually applying the player movement
func _physics_process(delta):
	playerVelocity.y -= gravity * delta

	localDir = move_and_slide(localDir * move_speed, Vector3.UP)

	var forwardDir = global_transform.basis.z
	var sidewaysDir = global_transform.basis.x

	localDir = (forwardDir * playerVelocity.z + sidewaysDir * playerVelocity.x + Vector3.UP * playerVelocity.y).normalized()

	if jumpingState:
		playerVelocity.y = jump_strength * 100 * delta
	else:
		pass
# Makes sure we stop falling when we hit the ground, so we don't
# zip right through it eventually
	if is_on_floor() and playerVelocity.y < 0:
		playerVelocity.y = 0

# Gets player inputs for things like movement, shooting, and jumping
func PlayerInputs(_delta):
	playerVelocity.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	playerVelocity.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if Input.is_action_just_pressed("fire"):
		emit_signal("shoot_attempt")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumpingState = true
	else:
		jumpingState = false

# For some reason I was unable to ever figure out changes in mouse position
# without having to separate it from the rest of the controls, so I decided
# to just get it from a specific input event
func _input(event):
	if event is InputEventMouseMotion:
		var movement = event.relative
		camera.rotation.x += -deg2rad(movement.y * mouseSens)
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(minLookAngle), deg2rad(maxLookAngle))
		rotation.y += -deg2rad(movement.x * mouseSens)
