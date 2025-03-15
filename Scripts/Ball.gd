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

var radius: float




func launch_downwards(vel: Vector2):
	linear_velocity = vel

func _physics_process(delta):
	if endgame_sinking:
		linear_velocity.y -=  Global.standard_gravity * delta
		linear_velocity.y = max(linear_velocity.y, -30)
	
	
func _integrate_forces(state):
	if in_water:
		var aprox_submerged = max(cur_water_level - global_position.y, 2 * radius) / (2 * radius)
		var buoyant_force = Global.water_density * aprox_submerged * volume * Global.standard_gravity
		state.add_central_force(Vector2(0, -buoyant_force))
		print("Buoyant Force: " + str(buoyant_force))

		

# recieve signal for when something collides with the ball
func _on_body_entered(body: Node) -> void:
	if body is Bumpers:
		(body as Bumpers).bumper_hit() 
	
	# play sound:
	var volMod = ( (abs(linear_velocity.x) + abs(linear_velocity.y) ) / 2.0 ) / 20.0
	volMod = clamp(volMod - 30.0, -50.0, 5.0)
	print("HIT " + str(volMod))
	SoundManager2D.SetSoundPoolVolume("SP_hit", volMod)
	SoundManager2D.PlaySoundPool2D("SP_hit")
	

func destroy_ball():
	# We'll either make this send a signal or have the game logic code check whether or not the ball is considered "recoverable" despite its demise
	queue_free()


func load_specifics(given_mass: float, given_radius: float, given_color: Color, strafe_mod: float):
	if given_mass <= 0:
		self.mass = def_mass
	else:
		self.mass = given_mass

	if given_radius <= 0:
		self.radius = def_radius
	else:
		self.radius = given_radius
	
	if given_color == null:
		self.color = def_color
	else:
		self.color = given_color

	volume = PI * radius * radius
	density = mass / volume

	col.shape.radius = radius
	obj_mesh.mesh.radius = radius
	obj_mesh.mesh.height = radius * 2
	
func transfer_out_of_water():
	in_water = false

func transfer_into_water(water_level: float):
	in_water = true
	cur_water_level = water_level
	print("in water")
	

