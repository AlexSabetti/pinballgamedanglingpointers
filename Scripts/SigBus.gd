class_name SigBus
extends Node

# signals for paddles
signal left_paddle(pressed: bool)
signal right_paddle(pressed: bool)

# signals for ballLauncher
signal start_ball_launch()
signal finish_ball_launch()

# For the shop / ui
signal update_stats()
signal add_points(points: int)
