extends Control
var progress = []
var SceneName
var scene_load_stats = 0
@onready var value = $Label
@onready var barload = $barload
@onready var camera_pivot = $Camerapivot
var rotation_speed = 15

func _ready():
	music_controller.stop()
	SceneName = global.scene
	ResourceLoader.load_threaded_request(SceneName)

func _process(delta):
	camera_pivot.rotation_degrees.y+=delta * rotation_speed
	scene_load_stats  = ResourceLoader.load_threaded_get_status(SceneName,progress)
	if barload.value < 100:
		value.text = str(floor(progress[0]*100)) + "%"
		barload.value = floor(progress[0]*100)
	elif  barload.value >= 100:
		value.text = str(floor(100)) + "%"
		barload.value = 100
	if scene_load_stats == ResourceLoader.THREAD_LOAD_LOADED:
		var NewScene = ResourceLoader.load_threaded_get(SceneName)
		await  get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_packed(NewScene)
