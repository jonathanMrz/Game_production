extends Control
var select_fase_menu = false
@onready var animationtitle = $AnimationPlayer3
@onready var animationback = $AnimationPlayer2
@onready var animation = $AnimationPlayer
@onready var skull = $skullpivot/Skull
@onready var skullpivot = $skullpivot
func _ready():
	music_controller.play_music(load("res://sound/music/audio1.mp3"))
	$AnimationPlayer4.play("fadin")
	animationtitle.play("titleanimation")
	animationback.play("skullanimation")
func _process(delta):
	if Input.is_action_just_pressed("Esc") and select_fase_menu:
		select_fase_menu = false
		$TrueClickSound.play()
		animation.play("BackSelectFase")
#Main_menu
func _on_button_pressed():
	$TrueClickSound.play()
	animation.play("SelectFase")
	select_fase_menu = true
	pass # Replace with function body.
func _on_button_2_pressed():
	$FalseClickSound.play()
	pass # Replace with function body.
func _on_button_3_pressed():
	$LeaveClickSound.play()
	$AnimationPlayer4.play("fadon")
	await  get_tree().create_timer(1.2).timeout
	get_tree().quit()
	pass # Replace with function body.

#Fase_select
func _on_back_pressed():
	if select_fase_menu:
		$TrueClickSound.play()
		select_fase_menu = false
		animation.play("BackSelectFase")
	pass # Replace with function body.
func _on_zero_pressed():
	$FaseClickSound.play()
	global.scene = "res://worlds/prologo.tscn"
	get_tree().change_scene_to_file(global.loadingscreen)
	pass # Replace with function body.
func _on_one_pressed():
	$FaseClickSound.play()
	$AnimationPlayer4.play("fadon")
	await  get_tree().create_timer(1.5).timeout
	global.scene = "res://worlds/server_1.tscn"
	get_tree().change_scene_to_file(global.loadingscreen)
	pass # Replace with function body.

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		skull.rotate_y(event.relative.x * 0.0009)
		
		skullpivot.rotate_x(event.relative.y * 0.0009)
		skullpivot.rotation.x = clamp(skullpivot.rotation.x, deg_to_rad(-100), deg_to_rad(45))

