@tool
class_name Paddle
extends Node2D

# resting rotation of the flipper
@export var resting_rotation:float = 0.0:
	set(rot):
		resting_rotation = rot
		$Origin/RigidBody2D.rotation_degrees = resting_rotation
# max target rotation of the flipper
@export var max_rotation:float = 45.0 
@export var paddle_power:float = 4.0
#@export var paddle_maxAccel:float = 1.0
var paddle_accel:float = 0.0
var rot_direction:int
@export var isLeftPaddle:bool = false
@export var isRightPaddle:bool = false
var paddle_btn_pressed:bool = false
var isRotating:bool = false

var signal_manager: SigBus = Manager

@onready var RotationAxis := $Origin/RigidBody2D
@onready var CollisionShape := $Origin/RigidBody2D/CollisionShape2D
@onready var defaultPaddlePoly := $Origin/RigidBody2D/DefaultPaddlePoly
@onready var leftPaddlePoly := $Origin/RigidBody2D/LeftPaddlePoly
@onready var rightPaddlePoly := $Origin/RigidBody2D/RightPaddlePoly

func _ready() -> void:
	set_process_input(true)
	leftPaddlePoly.visible = false
	rightPaddlePoly.visible = false
	if isLeftPaddle:
		signal_manager.connect("left_paddle", _paddle_signal)
		CollisionShape.rotation_degrees = 180.0
		defaultPaddlePoly.visible = false
		leftPaddlePoly.visible = true
	if isRightPaddle:
		signal_manager.connect("right_paddle", _paddle_signal)
		CollisionShape.rotation_degrees = 0.0
		defaultPaddlePoly.visible = false
		rightPaddlePoly.visible = true
	  
	# set starting position
	RotationAxis.rotation_degrees = resting_rotation
	# figure out what direction this flipper will be rotating
	if resting_rotation < max_rotation:
		rot_direction = 1
	else:
		rot_direction = -1


func _process(delta: float) -> void:
	#checks if in editor, only runs these processes if running game
	if !Engine.is_editor_hint():
		
		# rotate paddle when paddle button is pressed
		if paddle_btn_pressed:
			rotate_paddle(rot_direction * paddle_accel * 2)
			if RotationAxis.rotation_degrees != max_rotation:
				paddle_accel += paddle_power * 3 * delta
		else:
			if RotationAxis.rotation_degrees != resting_rotation:
				rotate_paddle(rot_direction * paddle_accel)
				if paddle_accel > -1 * paddle_power:
					paddle_accel -= paddle_power * 6 * delta
		# clamps the paddle acceleration to paddle_power
		paddle_accel = clamp(paddle_accel, -1 * paddle_power, paddle_power)
		

# restrains the paddle rotation to it's min and max
func restrain_rot() -> void:
	# apply restraints on rotation to keep the paddle from rotating too much
	if rot_direction > 0:
		if RotationAxis.rotation_degrees > max_rotation:
			RotationAxis.rotation_degrees = max_rotation
			paddle_accel = 0.0
		else: if RotationAxis.rotation_degrees < resting_rotation:
			RotationAxis.rotation_degrees = resting_rotation
			paddle_accel = 0.0
	else:
		if RotationAxis.rotation_degrees < max_rotation:
			RotationAxis.rotation_degrees = max_rotation
			paddle_accel = 0.0
		else: if RotationAxis.rotation_degrees > resting_rotation:
			RotationAxis.rotation_degrees = resting_rotation
			paddle_accel = 0.0

# paddle signal 
func _paddle_signal(pressed:bool):
	if pressed:
		paddle_btn_pressed = true
	else:
		paddle_btn_pressed = false

# adds the given degrees to the paddles rotation
func rotate_paddle(rot_deg:float) -> void:
	RotationAxis.rotation_degrees += rot_deg
	# apply restrains on rotation
	restrain_rot()
