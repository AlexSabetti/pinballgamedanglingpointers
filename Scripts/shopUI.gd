class_name shopUI
extends CanvasLayer

var signal_manager: SigBus = Manager

@onready var ball_mass_label: Label = $MarginContainer/MarginContainer/VBoxContainer/StatBox/MassLabel
@onready var points_label: Label = $MarginContainer/MarginContainer/VBoxContainer/ScoreLabel
@onready var balls_left_label: Label = $MarginContainer/MarginContainer/VBoxContainer/StatBox/BallLabel
@onready var new_ball_button: Button = $MarginContainer/MarginContainer/VBoxContainer/BallBox/BallButton
@onready var mass_button: Button = $MarginContainer/MarginContainer/VBoxContainer/MassBox/MassButton
@onready var strafe_button: Button = $MarginContainer/MarginContainer/VBoxContainer/StrafeBox/StrafeButton

@export var ball_mass_cost: int = 1000
@export var ball_cost: int = 200
@export var strafe_cost: int = 300

@export var ball_strafe_increase: float = 0.1
@export var mass_increase: int = 10

@export var ball_mass_cost_increase_percentage: float = 1.5
@export var ball_cost_increase_percentage: float = 2.5
@export var ball_strafe_increase_percentage: float = 1.1


var cur_points = 0
func _ready():
	print("Shop UI Ready!")
	signal_manager.connect("add_points", update_points)
	ball_mass_label.text = "Ball Mass: " + str(Global.gameLogic.current_ball_mass)
	mass_button.text = str(ball_mass_cost) + " pts"
	strafe_button.text = str(strafe_cost) + " pts"
	


func redeem_points(points: int):
	if cur_points >= points:
		cur_points -= points
		points_label.text = "Points: " + str(cur_points)
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
	if redeem_points(ball_mass_cost):
		Global.gameLogic.cur_strafe_mod += ball_strafe_increase
		strafe_cost = int(strafe_cost * ball_strafe_increase_percentage)
		strafe_button.text = str(int(strafe_cost * ball_strafe_increase_percentage)) + " pts"
	else:
		print("Not enough points")
		# Either put a pop-up or a sound effect

func update_points(points: int):
	print("Points: " + str(points))
	cur_points += points
	points_label.text = "Points: " + str(cur_points)
