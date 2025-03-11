class_name Ball
extends RigidBody2D

@export var def_mass: float
@export var radius: float

@export var color: Color

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var obj_mesh: MeshInstance2D = $MeshInstance2D

var endgame_sinking: bool = false
var 
func _ready():
	

func launch_downwards(vel: Vector2):
	linear_velocity = vel

func _physics_process(delta):



func destroy_ball():
	# We'll either make this send a signal or have the game logic code check whether or not the ball is considered "recoverable" despite its demise
	queue_free()

