extends Node

var game = preload("res://Level1.tscn")

func reset_game():
	get_tree().get_root().get_node("PS1Filter/SubViewport/Level1").queue_free()
	await get_tree().create_timer(1.0).timeout # wait for 1 second
	get_tree().get_root().get_node("PS1Filter/SubViewport").add_child(game.instantiate())
