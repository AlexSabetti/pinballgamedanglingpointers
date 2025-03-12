class_name Ball
extends RigidBody2D

@export var def_mass: float
@export var radius: float

@export var color: Color

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var obj_mesh: MeshInstance2D = $MeshInstance2D

var endgame_sinking: bool = false
#var 
func _ready():
	pass

func launch_downwards(vel: Vector2):
	linear_velocity = vel

func _physics_process(_delta):
	pass

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
