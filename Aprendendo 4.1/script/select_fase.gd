extends Control

func _on_button_pressed():
	get_tree().change_scene_to_file("res://worlds/prologo.tscn")
	pass # Replace with function body.


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://worlds/server_1.tscn")
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_just_pressed("Esc"):
		get_tree().change_scene_to_file("res://main_menu/menu.tscn")
