@tool
class_name WaterArea
extends Area2D

@export var waterSurfaceRef: Water2D

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	print("entered " + body.name)
	if body is Ball:
		var ball = body as Ball
		ball.transfer_into_water(global_position.y + (global_position.y / 2))
		
		# play splash sound when entering water from surface level
		if waterSurfaceRef and waterSurfaceRef.is_water_surface:
			SoundManager2D.PlaySoundQueue2D("SQ_splash")
		
		# ripples water surface when entering water
		if waterSurfaceRef != null:
			#print("splish!")
			# add force to water surface
			waterSurfaceRef.apply_force(ball.global_position, 128 * Vector2.DOWN, ball.def_radius * 4)
		
		if Global.underWaterAmbi:
			Global.underWaterAmbi.toggle(true)
	

func _on_body_exited(body):
	print("exited " + body.name)
	if body is Ball:
		var ball = body as Ball
		ball.transfer_out_of_water()
		
		# lightly ripples water surface when exiting water
		if waterSurfaceRef != null:
			#print("splash!")
			# add force to water surface
			waterSurfaceRef.apply_force(ball.global_position, 64 * Vector2.UP, ball.def_radius * 4)
		
		if Global.underWaterAmbi:
			Global.underWaterAmbi.toggle(false)
