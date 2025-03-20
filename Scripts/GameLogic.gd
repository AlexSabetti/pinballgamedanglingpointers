class_name GameLogic
extends Node2D

var signal_manager: SigBus = Manager

@export var cur_camera:Camera2D
@export var free_cam:bool = false

@export var cur_points := 0
@export var num_balls: int = 3

@onready var game_ui: shopUI = $UI_game

var current_ball_mass: float = 10.0
var current_ball_radius: float = 8
var cur_strafe_mod = 1.0

# whether or not there is a ball in play on the board
var is_ball_in_play:bool = false
var is_ball_launch_prep:bool = false

func _ready() -> void:
	Global.gameLogic = self
	print("GameLogic Ready!")
	


func _process(_delta: float) -> void:
	checkInput()

# checks for user input
func checkInput() -> void:
	
	# check left paddle input
	if Input.is_action_just_pressed("paddle_left"):
		#print("paddle left btn pressed")
		signal_manager.emit_signal("left_paddle", true)
	else: if Input.is_action_just_released("paddle_left"):
		#print("paddle left btn released")
		signal_manager.emit_signal("left_paddle", false)
	
	# check right paddle input
	if Input.is_action_just_pressed("paddle_right"):
		#print("paddle right btn pressed")
		signal_manager.emit_signal("right_paddle", true)
	else: if Input.is_action_just_released("paddle_right"):
		#print("paddle right btn released")
		signal_manager.emit_signal("right_paddle", false)
	
	if is_ball_in_play:
		if Input.is_action_just_pressed("return_ball"):
			pass
	else:
		# checks if user has pressed the button to begin launching the ball
		# only alowed if a ball is not already in play & the player has at least 1 ball avaiable for use
		if Input.is_action_just_pressed("launch_ball") and !is_ball_launch_prep and num_balls >= 1:
			is_ball_launch_prep = true
			signal_manager.emit_signal("start_ball_launch")
		
		# checks for when player releases the launch ball button
		if Input.is_action_just_released("launch_ball") and is_ball_launch_prep:
			is_ball_launch_prep = false
			is_ball_in_play = true
			signal_manager.emit_signal("finish_ball_launch")
		
	
	

# updates the current points by the given amount
func update_points(points: int):
	cur_points += points

func redeem_points(points: int):
	if cur_points >= points:
		cur_points -= points
		return true
	else:
		return false

func _on_ball_lost():
	num_balls -= 1
	if num_balls <= 0:
		print("Game Over")
		# end game here
	else:
		var main_node = get_tree().get_root().get_node("Main/Balls")
		var ball_scene = load("res://Scenes/Ball.tscn")
		var inst = ball_scene.instantiate()
		inst.load_specifics(current_ball_mass, current_ball_radius, Color.BROWN, cur_strafe_mod)
		main_node.add_child(inst)
		inst.launch_downwards(Vector2(0, -100))

# sets the current ball mass to the given value
func _on_mass_update(mass: float):
	current_ball_mass = mass

# sets the current ball radius to the given value
func _on_radius_update(radius: float):
	current_ball_radius = radius
