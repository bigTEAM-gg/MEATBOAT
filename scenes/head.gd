extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$ResetTimer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	$ColorRect.color.a += 0.01


func _on_reset_timer_timeout():
	Global.reset_game()
