#class_name SoundManager3D
extends Node2D

var SoundQueuesByName := {}
var SoundPoolsByName := {}

func _ready() -> void:
	SoundQueuesByName = {
		"SQ_boink" : $SQ_boink,
		"SQ_splash" : $SQ_splash,
	}
	SoundPoolsByName = {
		"SP_hit" : $SP_hit
	}
	

func SetSoundPoolVolume(soundPoolName:String, volume:float) -> void:
	if SoundPoolsByName[soundPoolName]:
		SoundPoolsByName[soundPoolName].setVolumeDBModifier(volume)

func PlaySoundPool2D(soundPoolName:String)->void:
	if SoundPoolsByName[soundPoolName]:
		SoundPoolsByName[soundPoolName].PlayRandomSound()
	else:
		print("Invalid soundPool name")

func PlaySoundQueue2D(soundQueueName:String)->void:
	if SoundQueuesByName[soundQueueName]:
		SoundQueuesByName[soundQueueName].PlaySound()
	else:
		print("Invalid soundQueue name")
