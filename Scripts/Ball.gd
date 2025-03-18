class_name Ball
extends RigidBody2D

@export var def_mass: float = 10
@export var def_radius: float = 8

@export var def_color: Color

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var obj_mesh: MeshInstance2D = $MeshInstance2D

var endgame_sinking: bool = false

var in_water: bool = false
var volume: float

var density: float

var cur_water_level: float

func _ready():
	if volume == null or volume == 0:
		volume = PI * def_radius * def_radius
		print("Volume: " + str(volume))
	if density == null or density == 0:
		density = def_mass / volume

func launch_downwards(vel: Vector2):
	linear_velocity = vel

func _physics_process(delta):
	#print("Ball: " + str(global_position))
	if endgame_sinking:
		linear_velocity.y -=  Global.standard_gravity * delta
		linear_velocity.y = max(linear_velocity.y, -30)
	else:
		# check left ball control input
		if Input.is_action_pressed("move_left"):
			linear_velocity.x += -0.5
			linear_velocity.x = max(linear_velocity.x, -20) 
		# else: if Input.is_action_just_released("move_left"):
		# 	linear_velocity.x += 0.5
		# 	linear_velocity.x = min(linear_velocity.x, 20)
		
		# check right ball control input
		if Input.is_action_pressed("move_right"):
			linear_velocity.x += 0.5
			linear_velocity.x = min(linear_velocity.x, 20)
		
	# else: if Input.is_action_just_released("move_right"):
	# 	signal_manager.emit_signal("move_ball_right", false)


func _integrate_forces(state):
	if in_water:
		print("y pos: " + str(global_position.y))
		print(minf((global_position.y + def_radius) - cur_water_level, 2 * def_radius))
		var aprox_submerged = global_position.y + def_radius - cur_water_level
		if(aprox_submerged < 0):
			aprox_submerged = 0
		elif aprox_submerged > 2 * def_radius:
			aprox_submerged = 2 * def_radius
		print("submerged by: " + str(aprox_submerged))
		print("volume: " + str(volume))
		var buoyant_force =  (Global.water_density * aprox_submerged * Global.standard_gravity) - (density * volume * Global.standard_gravity)
		state.apply_central_force(Vector2(0, buoyant_force))
		print("Buoyant Force: " + str(buoyant_force))

# recieve signal for when something collides with the ball
func _on_body_entered(body: Node) -> void:
	# if the ball collides with a bumper
	if body is Bumper:
		(body as Bumper).bumper_hit() 
		print("bumper hit!")
	
	# play sound:
	var volMod = ( (abs(linear_velocity.x) + abs(linear_velocity.y) ) / 2.0 ) / 20.0
	volMod = clamp(volMod - 30.0, -50.0, 5.0)
	print("HIT " + str(body))
	SoundManager2D.SetSoundPoolVolume("SP_hit", volMod)
	SoundManager2D.PlaySoundPool2D("SP_hit")
	

func destroy_ball():
	# We'll either make this send a signal or have the game logic code check whether or not the ball is considered "recoverable" despite its demise
	queue_free()


func load_specifics(given_mass: float, given_radius: float, given_color: Color, strafe_mod: float):
	if given_mass > 0:
		self.def_mass = given_mass

	if given_radius > 0:
		self.def_radius = given_radius
	
	if given_color == null:
		self.color = def_color
	else:
		self.color = given_color

	volume = PI * def_radius * def_radius
	density = def_mass / volume

	col.shape.radius = def_radius
	obj_mesh.mesh.radius = def_radius
	obj_mesh.mesh.height = def_radius * 2
	
func transfer_out_of_water():
	in_water = false
	print("out of water")

func transfer_into_water(water_level: float):
	in_water = true
	cur_water_level = water_level
	print("in water")
	
