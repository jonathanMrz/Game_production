extends Node
var paused = false
@onready var pause_menu = $Pause_menu
@onready var crossair = $Crossair

func _process(delta):
	
	#pause
	if Input.is_action_just_pressed("Esc"):
		paused = !paused
	if paused:
		crossair.visible = false
		pause_menu.visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif !paused:
		crossair.visible = true
		pause_menu.visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_resume_pressed():
	$TrueClickSound.play()
	paused = false
	pass

func _on_quit_pressed():
	$FaseClickSound.play()
	$AnimationPlayer.play("fadon")
	await  get_tree().create_timer(1.5).timeout
	get_tree().paused = false
	global.scene = "res://main_menu/menu.tscn"
	get_tree().change_scene_to_file(global.loadingscreen)
	pass
