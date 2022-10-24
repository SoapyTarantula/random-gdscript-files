# Badly designed by SoapyTarantula
# https://github.com/SoapyTarantula | https://twitter.com/SoapyTarantula

extends KinematicBody2D

export var MoveAndCollide = false # Use move_and_collide if true, else move_and_slide is used
export var movespeed = 300 # Pixels per second, if Godot is to be believed
export var ConfineToScreen = true # Limits position to within the viewport
export var startingPosition = Vector2() # Starting position on screen
export var player_extents = 0 # Used in ConfineToScreen()
export var UseProjectGravity = false; # If true this will grab the gravity from Godot's project settings
export var gravitySetting: float = 80 # Speed value used to accelerate the player down if the above is false
export var longJumpGravityMulti = 4 # Gravity multiplier when we hold the jump key
export var shortJumpGravityMulti = 16 # Gravity multiplier when we're not holding jump
export var jumpStrength = 10000

var moveDir = Vector2()
var velocity = Vector2.ZERO # Used for falling and jumping
var screen_size
var gravity: float

# Walmart brand state machine lol
var is_falling = false
var is_jumping = false

func _ready():
	if player_extents == 0: # Assuming 0 means we aren't specifying it ourselves
		player_extents = $CollisionShape2D.shape.extents
	screen_size = get_viewport().size
	PlaceAtPoint(Vector2(startingPosition.x, startingPosition.y))

	if UseProjectGravity == true:
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	else:
		gravity = gravitySetting

func _process(_delta):
	Inputs()
	if ConfineToScreen:
		KeepInsideScreen()

func _physics_process(delta):

	# Applying gravity and the faster falling
	# if the player is not holding down
	# the jump button or hasn't spent
	# enough time falling yet.

	if Input.is_action_pressed("jump") and !is_falling:
		velocity.y += gravity * longJumpGravityMulti * delta
	else:
		velocity.y += gravity * shortJumpGravityMulti * delta
	velocity = move_and_slide(velocity, Vector2.UP)

	# Handles actually jumping up
	# and resets the vertical velocity
	# when touching the ground, as well
	# as resetting the is_falling bool

	if is_on_floor() and is_jumping:
		velocity.y -= jumpStrength * 3 * delta
	if is_on_floor() and !is_jumping:
		is_falling = false
		velocity.y = 0

	# Horizontal movement for move_and_collide
	# or move_and_slide depending on what we're using

	if !MoveAndCollide:
		moveDir = move_and_slide(moveDir.normalized() * movespeed)
	else:
		moveDir = move_and_collide(moveDir.normalized() * movespeed * delta)

# Limit the KinematicBody2D to the view area.
# Could probably use some refining.

func KeepInsideScreen():
	position.x = clamp(position.x, 0 + player_extents.x, screen_size.x - player_extents.x)
	position.y = clamp(position.y, 0 + player_extents.y, screen_size.y - player_extents.y)

# Player inputs for left, right, and jumping.
# I wish Godot defaulted to WASD instead of arrows

func Inputs():
	moveDir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if Input.is_action_just_pressed("jump"):
		$"Jump Timer".start() # Begins the timer I use for mario-jumping
		is_jumping = true
	else:
		is_jumping = false

# Places the KinematicBody2D this script is attached to
# at a specific point on screen.
# Called in _ready()

func PlaceAtPoint(placePosition):
	position = placePosition

# Used to determine when the player should
# begin falling faster, for snappier jumps.

func _on_Jump_Timer_timeout():
	is_falling = true

# Used for debugging the mario-jump.
# Timer is set to timeout 4 times a second
# to avoid debugger spam because Godot has
# a really small line limit on the debugger.

func _on_Debug_Timer_timeout():
	#print(is_falling, " | ", Input.is_action_pressed("jump"), " | ", velocity.y)
	pass
