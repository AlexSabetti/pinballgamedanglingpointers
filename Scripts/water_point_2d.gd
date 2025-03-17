@tool
# represents a point in the water2D surface
# Based on code from: https://github.com/HackTrout/2DDynamicWater/tree/main
class_name waterPoint2D
extends Node2D

var motion:= Vector2.ZERO
@export var damping := 0.0

func _physics_process(delta: float) -> void:
	# apply motion
	position += motion * delta
	# apply damping
	motion *= damping


func calculate_motion(target_point: Vector2, stiffness: float = 1.0) -> Vector2:
	return (target_point - global_position) * stiffness
