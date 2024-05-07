extends Area3D

var jump = preload("res://scenes/JumpscareBoi/dat_jumpscare.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("Player"):
		await get_tree().create_timer(3).timeout
		var j = jump.instantiate()
		j.global_position = $"../JumpscareSpawn".global_position
		get_parent().add_child(j)
		$DoorSlam.play()
		await get_tree().create_timer(3).timeout
		$DoorLock.play()
