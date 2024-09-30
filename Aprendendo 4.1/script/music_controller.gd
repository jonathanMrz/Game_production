extends Node
@onready var music = $Music
func _ready():
	pass

func play_music(value):
	music.set_stream(value)
	music.play()

func music_pitch(value):
	music.set_pitch_scale(value)
func stop():
	music.stop()
