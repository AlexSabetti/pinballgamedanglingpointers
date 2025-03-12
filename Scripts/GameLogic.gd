class_name GameLogic
extends Node2D

var signal_manager: SignalBus = SignalManager

func _ready() -> void:
	Global.gameLogic = self
	print("GameLogic Ready!")


func _process(_delta: float) -> void:
	checkInput()

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
	
	# check left ball control input
	if Input.is_action_pressed("move_left"):
		signal_manager.emit_signal("move_ball_left", true)
	else: if Input.is_action_just_released("move_left"):
		signal_manager.emit_signal("move_ball_left", false)
		
	# check right ball control input
	if Input.is_action_pressed("move_right"):
		signal_manager.emit_signal("move_ball_right", true)
	else: if Input.is_action_just_released("move_right"):
		signal_manager.emit_signal("move_ball_right", false)
