@tool
extends Node2D

class_name SoundQueue2D

# the next audio stream player to play
var next := 0
# list of audio stream players to play
var audioStreamPlayers:Array[AudioStreamPlayer2D]

var rng := RandomNumberGenerator.new()

@export_category("Settings")
# how many instances of the audio stream player we want to use
@export var count := 1
@export var volumeDBModifier := 1.0:
	set(volMod):
		volumeDBModifier = volMod
var defaultVolumeDB:float
# range of pitch variation
@export var minPitch := 1.0
@export var maxPitch := 1.0
# range of volume variation
#@export var volumeRange := Vector2(1.0,1.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	update_configuration_warnings()
	
	# checks to make sure there's atleast 1 child
	if get_child_count() == 0:
		print("No AudioStreamPlayer2D child found!")
		return
	
	var child = get_child(0)
	if child is AudioStreamPlayer2D:
		var audioStreamPlayer := child as AudioStreamPlayer2D
		defaultVolumeDB = audioStreamPlayer.volume_db
		audioStreamPlayer.volume_db = volumeDBModifier
		audioStreamPlayers.push_back(audioStreamPlayer)
		
		var i = 0
		while i < count:
			var dupe:AudioStreamPlayer2D = audioStreamPlayer.duplicate() as AudioStreamPlayer2D
			add_child(dupe)
			audioStreamPlayers.push_back(dupe)
			i += 1
		
	pass # Replace with function body.

func _get_configuration_warnings():
	if get_child_count() == 0:
		return ["No children found. Expected one AudioStreamPlayer2D child."]
	
	if get_child(0) is not AudioStreamPlayer2D:
		return ["Expected first child to be an AudioStreamPlayer2D."]
	
	return 

# play sound
func PlaySound():
	if !audioStreamPlayers[next].playing:
		audioStreamPlayers[next].volume_db = volumeDBModifier
		audioStreamPlayers[next].pitch_scale = rng.randf_range(minPitch, maxPitch)
		audioStreamPlayers[next].play()
		next += 1
		# ensures field wraps back around to zero if goes over limit
		next %= audioStreamPlayers.size()
	

# play sound
func PlaySoundAt(pos:Vector2):
	if !audioStreamPlayers[next].playing:
		audioStreamPlayers[next].volume_db = volumeDBModifier
		audioStreamPlayers[next].pitch_scale = rng.randf_range(minPitch, maxPitch)
		audioStreamPlayers[next].position = pos
		audioStreamPlayers[next].play()
		next += 1
		# ensures field wraps back around to zero if goes over limit
		next %= audioStreamPlayers.size()
	
