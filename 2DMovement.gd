extends KinematicBody2D

export var MoveAndCollide = false
export var movespeed = 300
export var ConfineToScreen = true
var moveDir = Vector2()
var screen_size

func _ready():
	screen_size = get_viewport().size

func _process(_delta):
	Inputs()
	if ConfineToScreen:
		KeepInsideScreen()

func _physics_process(delta):
	if !MoveAndCollide:
		moveDir = move_and_slide(moveDir.normalized() * movespeed)
	else:
		moveDir = move_and_collide(moveDir.normalized() * movespeed * delta)

func KeepInsideScreen():
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

# For some reason I've never had any fucking luck getting the inputs to translate correctly
# unless they are in *exactly* the configuration below. If you modify this you may inherit
# the curse yourself and have all your characters move to the bottom right regardless
# of player input. ye be warned

func Inputs():
	moveDir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	moveDir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
