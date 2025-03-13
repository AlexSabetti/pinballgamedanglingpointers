class_name WaterArea
extends Area2D

var water_density: float = 1.0

func _on_body_entered(body):
	if body is Ball:
		var ball = body as Ball
		ball.linear_velocity.y += water_density * ball.linear_velocity.y
