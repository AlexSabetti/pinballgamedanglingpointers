class_name Ball
extends RigidBody2D

@export var def_mass: float = 10:
	set(given_mass):
		if given_mass > 0:
			def_mass = given_mass
			mass = given_mass
@export var def_radius: float = 8

@export var def_color: Color

var endgame_sinking: bool = false

var in_water: bool = false
var volume: float

var density: float

var cur_water_level: float

var depth_value: int = 0

var max_depth: int = 100

@export var strafe_mod: float = 1.0
var signal_manager: SigBus = Manager

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var obj_mesh: MeshInstance2D = $MeshInstance2D
@onready var SpriteAxis: Node2D = $SpriteAxis
@onready var Sprite: AnimatedSprite2D = $SpriteAxis/AnimatedSprite2D
@onready var leftArrow: Sprite2D = $ArrowAxis/Sprite2D_leftArrow
@onready var rightArrow: Sprite2D = $ArrowAxis/Sprite2D_rightArrow
var aprox_submerged = 0
var add_upwards_force = false
func _ready():
	if volume == null or volume == 0:
		volume = PI * def_radius * def_radius
		print("Volume: " + str(volume))
	if density == null or density == 0:
		density = def_mass / volume
	mass = def_mass
	
	# hide directional arrows
	leftArrow.visible = false
	rightArrow.visible = false
	
	Global.gameLogic.cur_ball = self

func launch_downwards(vel: Vector2):
	linear_velocity = vel

func add_velocity(vel: Vector2):
	linear_velocity += vel

func _process(_delta: float) -> void:
	depth_value = roundi((position.y - 142)/8)

func _physics_process(delta):
	#print("Ball: " + str(global_position))
	if endgame_sinking:
		linear_velocity.y -=  Global.standard_gravity
		linear_velocity.y = 125.0
	else:
		
		# check left ball control input
		if Input.is_action_just_pressed("move_left"):	# shows directional indicator on initial press
			linear_velocity.x += -1 * strafe_mod
			leftArrow.visible = true
		else: if Input.is_action_pressed("move_left"): # continues to move ball on hold
			linear_velocity.x += -1 * strafe_mod
		else: if Input.is_action_just_released("move_left"):
			# hides directional indicator on button release
			leftArrow.visible = false
		
		# check right ball control input
		if Input.is_action_just_pressed("move_right"):	# shows directional indicator on initial press
			linear_velocity.x += 1 * strafe_mod
			rightArrow.visible = true
		if Input.is_action_pressed("move_right"):	# continues to move ball on hold
			linear_velocity.x += 1 * strafe_mod
		else: if Input.is_action_just_released("move_right"):
			# hides directional indicator on button release
			rightArrow.visible = false

		if Input.is_action_pressed("move_up") and in_water:
			self.gravity_scale = 0.25
			add_upwards_force = true
		else:
			add_upwards_force = false
			self.gravity_scale = 1
		


func _integrate_forces(state):
	if in_water:
		
		#print("y pos: " + str(global_position.y))
		#print(minf((global_position.y + def_radius) - cur_water_level, 2 * def_radius))
		
		aprox_submerged = max((global_position.y - cur_water_level) / 700, 0.001)
		#print("aprox submerged: " + str(aprox_submerged))
		# if(aprox_submerged < 0):
		# 	aprox_submerged = 0
		# if(aprox_submerged > 2 * def_radius):
		# 	aprox_submerged = 2 * def_radius
		#print("submerged by: " + str(aprox_submerged))
		#print("volume: " + str(volume))
		var buoyant_force = 0
		if add_upwards_force:
			print(linear_velocity.y)
			buoyant_force = (Global.water_density * Global.standard_gravity + (Global.water_density * Global.standard_gravity * aprox_submerged)) - (density * Global.standard_gravity) # aprox_submerged *
			state.apply_central_force(Vector2(0, buoyant_force))
			linear_velocity.y = max(linear_velocity.y, -200);
		else:
			buoyant_force =  (Global.water_density * Global.standard_gravity + (Global.water_density * Global.standard_gravity * aprox_submerged)) - (density * Global.standard_gravity) # aprox_submerged *
			state.apply_central_force(Vector2(0, buoyant_force))
		# if state.linear_velocity.y < Global.water_density * 0.9 * Global.standard_gravity:
		# 	state.linear_velocity.y = Global.water_density * 0.9 * Global.standard_gravity
		#print("Buoyant Force: " + str(buoyant_force))

# recieve signal for when something collides with the ball
func _on_body_entered(body: Node) -> void:
	# if the ball collides with a bumper
	if body is Bumper and !(body as Bumper).bumperActivated:
		(body as Bumper).bumper_hit() 
		signal_manager.emit_signal("add_points", (body as Bumper).point_value)
		# bounce player away from bouncer
		var bounce_dir:Vector2 = (self.global_position - body.global_position).normalized() * abs(self.linear_velocity.length()) * 0.5
		add_velocity(bounce_dir)
		
		# makes ball grow after bounce for a little bit (only visually, doesn't affect gameplay)
		var tween = create_tween()
		tween.tween_property(SpriteAxis, "scale", Vector2(1.25,1.25), 0.5).from(Vector2(1.0,1.0)).set_trans(Tween.TRANS_BOUNCE)
		tween.chain().tween_property(SpriteAxis, "scale", Vector2(1.0,1.0), 0.25).set_trans(Tween.TRANS_BACK)
	
	# play hit sound on impact:
	var volMod = ( (abs(linear_velocity.x) + abs(linear_velocity.y) ) / 2.0 ) / 20.0
	volMod = clamp(volMod - 30.0, -50.0, 5.0)
	#print("HIT " + str(body))
	SoundManager2D.SetSoundPoolVolume("SP_hit", volMod)
	SoundManager2D.PlaySoundPool2DAt("SP_hit", position)
	

func destroy_ball():
	SoundManager2D.PlaySoundQueue2DAt("SQ_slip", position)
	Global.gameLogic.is_ball_in_play = false
	Global.gameLogic.check_game_over()
	print("ball destroyed")
	# We'll either make this send a signal or have the game logic code check whether or not the ball is considered "recoverable" despite its demise
	queue_free()


func load_specifics(given_mass: float, given_radius: float, strafe_modifier: float):
	if given_mass > 0:
		self.def_mass = given_mass
		mass = given_mass

	if given_radius > 0:
		self.def_radius = given_radius
	

	volume = PI * def_radius * def_radius
	density = def_mass / volume

	col= $CollisionShape2D
	obj_mesh = $MeshInstance2D

	col.shape.radius = def_radius
	obj_mesh.mesh.radius = def_radius
	obj_mesh.mesh.height = def_radius * 2
	strafe_mod = strafe_modifier



func transfer_out_of_water():
	in_water = false
	print("out of water")

func transfer_into_water(water_level: float):
	in_water = true
	cur_water_level = water_level
	print("in water")
	
