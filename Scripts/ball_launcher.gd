# entity from which balls are casted/launched
class_name BallLauncher
extends Node2D

# reference to the current ball to use
@export var currentBallRef:Ball
# where the ball gets launched from, relative  to the ballLaunchers position
@export var ballStartOffset:Vector2 = Vector2(0.0, -45.0)
var is_launching_ball:bool = false

var launch_power:float = 0.0 # the current launch power 
@export var max_launch_power:float = 100.0
@export var launch_power_change_rate:float = 6.0 # how fast the launch power fluctuates while preparing for launch
@export var launch_angle:float = 210.0 # angle at which to launch the ball

var time:float = 0.0

var signal_manager: SigBus = Manager

@onready var PowerLabel := $Label
# ballScene reference used for creating new balls
@onready var ballScene = preload("res://Ball2.tscn")

func _ready() -> void:
	signal_manager.connect("start_ball_launch", start_ball_launch)
	signal_manager.connect("finish_ball_launch", finish_ball_launch)

func _process(delta: float) -> void:
	# increase launch power
	if is_launching_ball:
		time += delta 
		launch_power = (max_launch_power/2.0) * sin(time * launch_power_change_rate) + (max_launch_power/2.0)
		PowerLabel.text = str(roundf(launch_power))
		#print("[" + str(time) + "] launch power: " + str(launch_power))
	

# begins the launch process, letting user choose launch power based on how long they hold down the launch key
func start_ball_launch() -> void:
	print("starting ball launch")
	time = 0.0
	launch_power = 0.0
	is_launching_ball = true


# ends the launch process, releasing the ball at the current launch power
func finish_ball_launch() -> void:
	print("finishing ball launch")
	# calculate launch velocity
	var launch_velocity = Vector2.RIGHT.rotated(deg_to_rad(launch_angle)) * launch_power * 6
	
	# instantiates new ball in current scene and moves it to proper starting point
	var ball: Ball = ballScene.instantiate()
	ball.load_specifics(Global.gameLogic.current_ball_mass, Global.gameLogic.current_ball_radius, Global.gameLogic.cur_strafe_mod)
	Global.gameLogic.subtract_ball()
	signal_manager.emit_signal("update_stats")
	add_sibling(ball)
	ball.position = position + ballStartOffset
	
	# launch ball
	ball.launch_downwards(launch_velocity)
	is_launching_ball = false
	print("ball launched: " + str(launch_velocity))
