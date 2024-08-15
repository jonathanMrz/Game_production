extends Control
var select_fase_menu = false
@onready var animationback = $AnimationPlayer2
@onready var animation = $AnimationPlayer
@onready var skull = $CraneoObj
func _ready():
	animationback.play("skullanimation")
func _process(delta):
	if Input.is_action_just_pressed("Esc") and select_fase_menu:
		select_fase_menu = false
		animation.play("BackSelectFase")
#Main_menu
func _on_button_pressed():
	animation.play("SelectFase")
	select_fase_menu = true
	pass # Replace with function body.
func _on_button_2_pressed():
	pass # Replace with function body.
func _on_button_3_pressed():
	get_tree().quit()
	pass # Replace with function body.

#Fase_select
func _on_zero_pressed():
	global.scene = "res://worlds/prologo.tscn"
	get_tree().change_scene_to_file(global.loadingscreen)
	pass # Replace with function body.
func _on_one_pressed():
	global.scene = "res://worlds/server_1.tscn"
	get_tree().change_scene_to_file(global.loadingscreen)
	pass # Replace with function body.

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		skull.rotate_y(event.relative.x * 0.0008)
