class_name Ball
extends RigidBody2D

@export var def_mass: float
@export var def_radius: float

@export var def_color: Color

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var obj_mesh: MeshInstance2D = $MeshInstance2D

var endgame_sinking: bool = false

var in_water: bool = false
var current_water_density: float
	



func launch_downwards(vel: Vector2):
	linear_velocity = vel

<<<<<<< HEAD
func _physics_process(delta):
	if endgame_sinking:
		linear_velocity.y -= 0.1 * delta
		linear_velocity.y = max(linear_velocity.y, -10)
	else:
		linear_velocity.y = gravity.y * mass * delta
	


# recieve signal for when something collides with the ball
func _on_body_entered(body: Node) -> void:
	if body is Bumper:
		(body as Bumper).bumper_hit() 
	
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
	
func transfer_out_of_water():
	in_water = false

func transfer_into_water(water_density: float):
	in_water = true
	current_water_density = water_density

