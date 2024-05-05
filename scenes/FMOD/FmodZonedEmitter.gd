@tool
extends StudioEventEmitter3D

@export var follow_player: bool = false

func _ready():
	if Engine.is_editor_hint():
		return
	stop_event = RuntimeUtils.GAMEEVENT_EXIT_TREE
	$Area3D.connect("body_entered", _on_static_body_3d_body_entered)
	$Area3D.connect("body_exited", _on_static_body_3d_body_exited)

func _get_configuration_warnings():
	if not is_instance_valid($Area3D):
		return ['Requires a child Area3D']
	return null


func _physics_process(delta):
	if follow_player:
		$Area3D.top_level = true
		var player = get_tree().get_nodes_in_group("Player")[0]
		global_position.x = player.global_position.x
		global_position.z = player.global_position.z


func _on_static_body_3d_body_entered(body):
	if body.is_in_group("Player"):
		play()


func _on_static_body_3d_body_exited(body):
	if body.is_in_group("Player"):
		stop()
