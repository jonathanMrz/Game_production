extends Node3D
class_name Checkpoint
@export var spawnpoint = false
var activated = false

func activate():
	activated = true
	Global.current_checkpoint = self

func _on_collision_shape_3d_tree_entered():
	activate()
