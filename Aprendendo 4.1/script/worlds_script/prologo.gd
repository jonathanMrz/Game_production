extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	music_controller.play_music(load("res://sound/music/prologo_music.mp3"))
