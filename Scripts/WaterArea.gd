class_name WaterArea
extends Area2D


func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	print("entered " + body.name)
	if body is Ball:
		var ball = body as Ball
		ball.transfer_into_water(global_position.y + (global_position.y / 2))

func _on_body_exited(body):
	print("entered " + body.name)
	if body is Ball:
		var ball = body as Ball
		ball.transfer_out_of_water()
