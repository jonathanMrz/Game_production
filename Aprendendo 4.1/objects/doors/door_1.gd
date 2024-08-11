extends Area3D
var inarea = false
var status = false
@onready var animation = $Node3D/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if inarea:
		$LabelPress.visible = true
		if Input.is_action_just_pressed("F"):
			if !status and (animation.get_current_animation_position() > 0.5 or animation.get_current_animation_position() == 0):
				animation.play("door_1_open")
				status = true
			elif status and animation.get_current_animation_position() > 0.5:
				animation.play("door_1_closed")
				status = false
	elif !inarea:
		$LabelPress.visible = false
	pass

func _on_body_entered(body):
	if body == global.player:
		inarea = true
	pass # Replace with function body.


func _on_body_exited(body):
	if body == global.player:
		inarea = false
		if status:
			await get_tree().create_timer(0.5).timeout
			animation.play("door_1_closed")
			status = false
		
	pass # Replace with function body.
