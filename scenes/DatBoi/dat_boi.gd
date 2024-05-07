extends CharacterBody3D

var walk_speed = 2.0
var chase_speed = 5.0
var movement_speed: float = 2.0
@export var movement_target: Node3D = null
@export var movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)

var seen_player = null

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export var PatrolNodes: Array[Vector3] = []
var patrol_index: int = 0

func _ready():
	$"CharRigWalkFlashlight/WGT-rig_hand_fk_L/AnimationPlayer".current_animation = "spinny"
	$"CharRigWalkFlashlight/WGT-rig_hand_fk_L/AnimationPlayer".play()
	$CharRigWalkFlashlight/AnimationPlayer.current_animation = "Armature|mixamo_com|Layer0_001 Retarget"
	$CharRigWalkFlashlight/AnimationPlayer.active = true
	$CharRigWalkFlashlight/AnimationPlayer.play()
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	$Timer.timeout.connect(func():
		if is_instance_valid(seen_player):
			set_movement_target(seen_player.global_position)
			return
		if PatrolNodes[patrol_index].distance_to(global_position) < 2.0:
			patrol_index = (patrol_index + 1) % len(PatrolNodes)
		set_movement_target(PatrolNodes[patrol_index]))

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	#set_movement_target(movement_target.global_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

var prev_look_position = Vector3.ZERO

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	velocity = new_velocity
	
	prev_look_position = prev_look_position.lerp(Vector3(next_path_position.x, global_position.y, next_path_position.z), 0.05)
	
	if is_instance_valid(seen_player):
		look_at(seen_player.global_position)
	else:
		look_at(prev_look_position)
	rotation.y += deg_to_rad(180)
	
	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	$CharRigWalkFlashlight/AnimationPlayer.play()


func _on_detect_box_body_entered(body):
	if body.is_in_group("Player"):
		$Scaries.play()
		set_movement_target(body.global_position)
		movement_speed = chase_speed
		seen_player = body


func _on_grab_box_body_entered(body):
	if body.is_in_group("Player"):
		body.kill()
