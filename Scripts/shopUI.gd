class_name shopUI
extends CanvasLayer

var signal_manager: SigBus = Manager

@onready var ball_mass_label: Label = $MarginContainer/MarginContainer/VBoxContainer/StatBox/MassLabel
@onready var points_label: Label = $MarginContainer/MarginContainer/VBoxContainer/ScoreLabel
@onready var balls_left_label: Label = $MarginContainer/MarginContainer/VBoxContainer/StatBox/BallLabel
@onready var new_ball_button: Button = $MarginContainer/MarginContainer/VBoxContainer/BallBox/BallButton
@onready var mass_button: Button = $MarginContainer/MarginContainer/VBoxContainer/MassBox/MassButton
@onready var strafe_button: Button = $MarginContainer/MarginContainer/VBoxContainer/StrafeBox/StrafeButton
@onready var depth_meter: Label = $ColorRect/MarginContainer/Label
@onready var fail_text: Label = $MarginContainer/MarginContainer/VBoxContainer/GameOver
@onready var restart_button: Button = $MarginContainer/MarginContainer/VBoxContainer/RestartButton

@export var ball_mass_cost: int = 30
@export var ball_cost: int = 100
@export var strafe_cost: int = 100

@export var ball_strafe_increase: float = 0.1
@export var mass_increase: float = 0.1

@export var ball_mass_cost_increase_percentage: float = 1.25
@export var ball_cost_increase_percentage: float = 1.15
@export var ball_strafe_increase_percentage: float = 1.1


var cur_points = 0
func _ready():
	print("Shop UI Ready!")
	
	ball_mass_label.text = "Ball Mass: " + str(get_parent().current_ball_mass)
	mass_button.text = str(ball_mass_cost) + " pts"
	strafe_button.text = str(strafe_cost) + " pts"
	restart_button.disabled = true
	restart_button.visible = false
	
	

func _process(_delta: float) -> void:
	if Global.gameLogic.cur_ball != null:
		depth_meter.text = "Depth: " + str(Global.gameLogic.cur_ball.depth_value)
	else:
		depth_meter.text = "Depth: "
	
	
func redeem_points(points: int):
	if cur_points >= points:
		cur_points -= points
		points_label.text = "Points: " + str(cur_points)
		Global.gameLogic.cur_points = cur_points
		return true
	else:
		return false

# tries to purchases a ball
func _on_ball_purchase():
	if redeem_points(ball_cost):
		Global.gameLogic.num_balls += 1
		balls_left_label.text = "Balls Left: " + str(Global.gameLogic.num_balls)
		ball_cost = int(ball_cost * ball_cost_increase_percentage)
		new_ball_button.text = str(ball_cost) + " pts"
		print("ball +1")
	else:
		print("Not enough points")
		# Either put a pop-up or a sound effect

func _on_mass_purchase():
	if redeem_points(ball_mass_cost):
		Global.gameLogic.current_ball_mass += mass_increase
		ball_mass_cost = int(ball_mass_cost * ball_mass_cost_increase_percentage)
		mass_button.text = str(ball_mass_cost) + " pts"

		ball_mass_label.text = "Ball Mass: " + str(Global.gameLogic.current_ball_mass)
	else:
		print("Not enough points")
		# Either put a pop-up or a sound effect

func _on_strafe_purchase():
	if redeem_points(strafe_cost):
		Global.gameLogic.cur_strafe_mod += ball_strafe_increase
		strafe_cost = int(strafe_cost * ball_strafe_increase_percentage)
		strafe_button.text = str(int(strafe_cost)) + " pts"
	else:
		print("Not enough points")
		# Either put a pop-up or a sound effect

func update_points(points: int):
	print("Points: " + str(points))
	cur_points = points
	points_label.text = "Points: " + str(cur_points)

func update_balls():
	balls_left_label.text = "Balls Left: " + str(Global.gameLogic.num_balls)


func _on_destroy_button_pressed() -> void:
	if Global.gameLogic.cur_ball != null:
		Global.gameLogic.cur_ball.destroy_ball()

func game_over():
	fail_text.visible = true
	restart_button.visible = true
	restart_button.disabled = false

func _on_restart_button():
	get_tree().reload_current_scene()
