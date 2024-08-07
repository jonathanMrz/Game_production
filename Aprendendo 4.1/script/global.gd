extends Node

var player :Player
var current_checkpoint :Checkpoint

func respawn_player():
	if current_checkpoint != null:
		player.position = current_checkpoint.global_position
