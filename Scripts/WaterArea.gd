@tool
class_name WaterArea
extends Area2D

@export var waterSurfaceRef: Water2D

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
	# check if water has a surface
	if get_parent().get_class() == "Water2D":
		waterSurfaceRef = get_parent()

func _on_body_entered(body):
	print("entered " + body.name)
	if body is Ball:
		var ball = body as Ball
		ball.transfer_into_water(global_position.y + (global_position.y / 2))
		
		if waterSurfaceRef != null:
			print("splish!")
			# add force to water surface
			waterSurfaceRef.apply_force(ball.global_position, 256 * Vector2.DOWN, ball.radius * 12)
		
	

func _on_body_exited(body):
	print("exited " + body.name)
	if body is Ball:
		var ball = body as Ball
		ball.transfer_out_of_water()
		
		if waterSurfaceRef != null:
			print("splash!")
			# add force to water surface
			waterSurfaceRef.apply_force(ball.global_position, 128 * Vector2.UP, ball.radius * 12)

