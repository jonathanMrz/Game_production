extends Node3D

@onready var player = $Player
@onready var player_ascene = preload("res://player/player.tscn" )
# Called when the node enters the scene tree for the first time.
func _ready():
	music_controller.play_music(load("res://sound/music/audio2.mp3"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
