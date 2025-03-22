@tool
# creates layer of points which make up a 2D water surface
# Based on code from: https://github.com/HackTrout/2DDynamicWater/tree/main
class_name Water2D
extends Node2D

@export var has_collision:bool = true
@export var is_water_surface:bool = true

@export_category("draw settings")
@export var draw_water:bool = true
@export var draw_water_overlay:bool = true
@export var draw_points:bool = false
@export var draw_neighbouring_springs:bool = false
@export var draw_area:bool = false

@export var draw_points_size:float = 5.0
@export var draw_spring_size:float = 3.0
@export var draw_spring_distance:float = 32.0
@export var surface_color:Color = Color(0.751, 0.777, 0.633, 1.0)
@export var water_color:Color = Color(0.375, 0.383, 0.299, 0.785)
@export var deep_water_color:Color = Color(0.332, 0.331, 0.256, 1.0)
@export var water_texture:Texture2D
@export var surface_width:float = 5.0 # how thick the surface line should be

@export_category("wave settings")
@export var waves_enabled:bool = true
@export var wave_height:float = 3.0
@export var wave_speed:float = 3.0
@export var wave_width:float = 8.0
@export var wave_spread_amount:int = 2 #How many times forces should be calculated between neighbouring points per frame. Higher values means waves travel faster

@export_category("surface point settings")
# how much distance there should be between points
@export var point_density = 8
# array of water points
var points = []

@export var point_damping := 0.99 #This is multiplied with a point's motion every frame. Smaller values mean waves will fade quicker
@export var point_independent_stiffness := 1.0 #Stiffness between a point and it's resting y pos.
@export var point_neighbouring_stiffness := 2.0 #Stiffness between neighbouring points. Higher values mean motion is transferred between points quicker.

# the collision polygon to base surface positions off of
var collision_polygon: CollisionPolygon2D
# first waterPoint location
var startPoint: Vector2
# last waterPoint location
var endPoint: Vector2

var delta_time = 0.0

#var polygon2D:Polygon2D

@onready var waterArea = $WaterArea
@onready var waterPointScene = preload("res://Scenes/Entities/waterPoint2D.tscn")

func _ready() -> void:
	# begins assigning variables and finding the collision polygon to base point positions off of
	for child in waterArea.get_children():
		if child.get_class() == "CollisionPolygon2D":
			# updates reference to collision polygon
			collision_polygon = child
			if collision_polygon.polygon.size() == 4:
				# sets start and end points of water surface
				startPoint = collision_polygon.polygon[0]
				endPoint = collision_polygon.polygon[1]
				
				# generate the surface points
				generate_surface_points()
				
				break
	
	if has_collision:
		waterArea.monitoring = true
		waterArea.monitorable = true
	else:
		waterArea.monitoring = false
		waterArea.monitorable = false
	
	#if draw_water:
		#polygon2D = Polygon2D.new()
		#polygon2D.set_polygon(PackedVector2Array([]))
		#add_child(polygon2D)

# generates water points across WaterArea surface
func generate_surface_points() -> void:
	print("generating surface points between " + str(startPoint) + " and " + str(endPoint))
	
	# number of points to generate
	var num_points = int(floor((endPoint.x - startPoint.x) / point_density))
	
	for i in range(num_points):
		var point = waterPointScene.instantiate()
		add_child(point)
		
		point.damping = point_damping
		
		point.position = Vector2(startPoint.x + (point_density * (i + 0.5)), startPoint.y)
		
		# append to points array
		points.append(point)

# clears the points queue and frees all water points
func destroy_surface_points() -> void:
	#Destroy WaterPoints along the Surface
	for point in points:
		point.queue_free()
	points.clear()

# processes physics for water surface and waves
func _physics_process(delta) -> void:
	# Delta Time
	if waves_enabled:
		delta_time += delta
		if delta_time > PI * 2.0:
			delta_time -= PI * 2.0
	
	# Update Points
	if collision_polygon != null:
		var target_y = global_position.y + startPoint.y
		for i in range(points.size()):
			# Calculate Motion for Point
			var point = points[i]
			point.motion += point.calculate_motion(Vector2(point.global_position.x, target_y), point_independent_stiffness)
			
			# Add Some Wave
			if waves_enabled:
				point.motion.y += sin(((i / float(points.size())) * wave_width) + (delta_time * wave_speed)) * (wave_height + randf_range(-2, 2))
			
			# Apply spring forces between neighbouring points
			for j in range(wave_spread_amount):
				# Point to Left
				if i - 1 >= 0:
					var left_point = points[i - 1]
					point.motion += point.calculate_motion(Vector2(point.global_position.x, left_point.global_position.y), point_neighbouring_stiffness)
				
				# Point to Right
				if i + 1 < points.size():
					var right_point = points[i + 1]
					point.motion += point.calculate_motion(Vector2(point.global_position.x, right_point.global_position.y), point_neighbouring_stiffness)
	
	##Apply force at mouse position
	#if Input.is_action_just_pressed("ui_accept"):
		#apply_force(get_global_mouse_position(), 64 * Vector2.DOWN, 48)
	
	
	#Draw Points
	queue_redraw()

# apply a force on the water surface at the given position
func apply_force(pos: Vector2, force: Vector2, width: float = 16.0) -> void:
	#Ignore if pos is outside area
	if (points[0].global_position.x - width) > pos.x || (points[points.size() - 1].global_position.x + width) < pos.x:
		return
	
	#Convert global coords to local coords
	var local_pos = to_local(pos)
	
	#Find the furthest positions that could be affected to the left and right
	var left_most = local_pos.x - (width / 2.0)
	var right_most = local_pos.x + (width / 2.0)
	
	#Convert those local positions to indices in the "points" array
	var left_most_index = get_index_from_local_pos(Vector2(left_most, local_pos.y))
	var right_most_index = get_index_from_local_pos(Vector2(right_most, local_pos.y))
	
	#Run through the indices and apply the force
	for i in range(left_most_index, right_most_index + 1):
		points[i].motion += force


# returns the index of the point in the points array that is closest to the given vector2 position
func get_index_from_local_pos(pos: Vector2) -> int:
	#Returns an index of the "points" array on water's surface to the local pos
	var index = floor((abs(startPoint.x - pos.x) / (endPoint.x - startPoint.x)) * points.size())
	
	#Ensure the index is a possible index of the array
	return int(clamp(index, 0, points.size() - 1))


# draws the waves 
func _draw() -> void:
	#Draw Points
	if collision_polygon != null:
		if draw_area:
			var area = collision_polygon.polygon
			var col = Color(0.0, 0.0, 1.0, 0.25)
			draw_polygon(area, [col, col, col, col])
		
		if draw_water:
			var surface = [startPoint]
			var polygon = [startPoint]
			#polygon2D.set_polygon(PackedVector2Array([startPoint]))
			var colors = [water_color]
			var UVs = [startPoint]
			for i in range(points.size()):
				#Append points
				surface.append(points[i].position)
				polygon.append(points[i].position)
				UVs.append(points[i].position)
				#polygon2D.polygon.append(points[i].position)
				colors.append(water_color)
			
			surface.append(endPoint)
			
			polygon.append(endPoint)
			UVs.append(endPoint)
			#polygon2D.polygon.append(endPoint)
			colors.append(water_color)
			polygon.append(collision_polygon.polygon[2])
			UVs.append(collision_polygon.polygon[2])
			#polygon2D.polygon.append(collision_polygon.polygon[2])
			colors.append(deep_water_color)
			polygon.append(collision_polygon.polygon[3])
			UVs.append(collision_polygon.polygon[3])
			#polygon2D.polygon.append(collision_polygon.polygon[3])
			colors.append(deep_water_color)
			
			draw_polygon(polygon, colors, UVs, water_texture)
			draw_polyline(surface, surface_color, surface_width)
		
		
		if draw_points:
			var target_y = startPoint.y
			for i in range(points.size()):
				var point = points[i]
				draw_circle(point.position, draw_points_size, Color.WHITE)
				
				#Draw Spring
				var w = 1.0 - (abs(point.position.y - target_y) / draw_spring_distance)
				draw_line(point.position, Vector2(point.position.x, target_y), Color.WHITE, draw_spring_size * w)
				
				#Draw Neighbouring Springs
				if draw_neighbouring_springs:
					#Point to Left
					if i - 1 >= 0:
						var left_point = points[i - 1]
						var lw = 1.0 - (abs(point.position.y - left_point.position.y) / draw_spring_distance)
						draw_line(point.position, left_point.position, Color.WHITE, draw_spring_size * lw)
					
					#Point to Right
					if i + 1 < points.size():
						var right_point = points[i + 1]
						var rw = 1.0 - (abs(point.position.y - right_point.position.y) / draw_spring_distance)
						draw_line(point.position, right_point.position, Color.WHITE, draw_spring_size * rw)
