extends Node

const HURT = preload("res://Sounds/hurt_sound.wav")
const JUMP = preload("res://Sounds/jump_sound.wav")

@onready var audioPlayers = $AudioPlayers

func play_sound(sound):
	for audioStreamPlayer in audioPlayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break
