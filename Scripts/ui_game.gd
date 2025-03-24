class_name HUD
extends CanvasLayer

var signal_manager: SigBus = Manager

@onready var ScoreLabel = $MarginContainer/MarginContainer/VBoxContainer/ScoreLabel

#updates score displayed on hud
func updateScore(score: int) -> void:
	ScoreLabel.text = "Points: " + str(score)
	pass

#updates stats displayed on hud
func updateStats() -> void:
	pass
