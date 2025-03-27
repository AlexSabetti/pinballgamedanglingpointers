class_name GameLogic
extends Node2D

var signal_manager: SigBus = Manager

@export_category("player properties")
@export var cur_points := 0
@export var num_balls: int = 3

@export_category("camera properties")
@export var cur_camera:Camera2D
@export var cam_follow:bool = true
@export var cam_follow_speed:float = 2.0
@export var camera_zoom:float = 0.9
@export var min_camera_zoom:float = 0.5
@export var max_camera_zoom:float = 1.5
var default_cam_position:Vector2 = Vector2(640.0, 482.0)

@export_category("ball properties")
@export var current_ball_mass: float = 1.0
@export var current_ball_radius: float = 8
@export var cur_strafe_mod = 1.5

@export var is_ball_in_play:bool = false # whether or not there is a ball in play on the board
var is_ball_launch_prep:bool = false

var cur_ball:Ball # reference to current ball in play that the camera should follow

@onready var game_ui:= $UI_game

func _ready() -> void:
	Global.gameLogic = self
	
	signal_manager.connect("add_points", update_points)
	
	print("GameLogic Ready!")
	
	# set up camera
	default_cam_position = cur_camera.global_position
	cur_camera.zoom = Vector2(camera_zoom, camera_zoom)


func _process(delta: float) -> void:
	checkInput()
	
	if cam_follow:
		camera_follow(delta)

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

# keep ball on screen by moving camera
func camera_follow(delta: float) -> void:
	if cur_ball != null:
		cur_camera.drag_horizontal_enabled = true
		cur_camera.drag_vertical_enabled = true
		cur_camera.global_position = lerp(cur_camera.global_position, cur_ball.global_position, delta * cam_follow_speed)
	else:
		cur_camera.global_position = lerp(cur_camera.global_position, default_cam_position, delta * cam_follow_speed * 1.75)
		cur_camera.drag_horizontal_enabled = false
		cur_camera.drag_vertical_enabled = false

# updates the current points by the given amount
func update_points(points: int):
	cur_points += points
	game_ui.update_points(cur_points)

func redeem_points(points: int):
	if cur_points >= points:
		cur_points -= points
		return true
	else:
		return false

# This isn't really needed anymore
# func _on_ball_lost():
# 	num_balls -= 1
# 	if num_balls <= 0:
# 		print("Game Over")
# 		# end game here
# 	else:
# 		var main_node = get_tree().get_root().get_node("Main/Balls")
# 		var ball_scene = load("res://Scenes/Ball.tscn")
# 		var inst = ball_scene.instantiate()
# 		inst.load_specifics(current_ball_mass, current_ball_radius, Color.BROWN, cur_strafe_mod)
# 		main_node.add_child(inst)
# 		inst.launch_downwards(Vector2(0, -100))

# sets the current ball mass to the given value
func _on_mass_update(mass: float):
	current_ball_mass = mass

# sets the current ball radius to the given value
func _on_radius_update(radius: float):
	current_ball_radius = radius

func subtract_ball():
	num_balls -= 1
	game_ui.update_balls()
	if num_balls <= 0:
		print("Game Over")
		# end game here

func add_ball():
	num_balls += 1
	game_ui.update_balls()

