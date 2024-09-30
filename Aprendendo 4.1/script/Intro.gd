extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	global.scene = "res://main_menu/menu.tscn"
	$AnimationPlayer.play("FadeIn")
	await  get_tree().create_timer(4).timeout
	$AnimationPlayer.play("FadeOut")
	await  get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file(global.loadingscreen)
func _process(delta):
	if Input.is_anything_pressed():
		get_tree().change_scene_to_file(global.loadingscreen)
