extends KinematicBody2D

export var movespeed = 300
var moveDir = Vector2()

# For some reason I've never had any fucking luck getting the inputs to translate correctly
# unless they are in *exactly* the configuration below. If you modify this you may inherit
# the curse yourself and have all your characters move to the bottom right regardless
# of player input. ye be warned

func _process(_delta):
	moveDir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	moveDir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

func _physics_process(_delta):
	move_and_slide(moveDir.normalized() * movespeed) # this line will throw a "returns a value but is never used" warning in the debugger and I don't fucking know why
