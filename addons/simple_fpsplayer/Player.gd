extends CharacterBody3D

var head = preload("res://scenes/head.tscn")

const ACCEL = 10
const DEACCEL = 30

const SPEED = 5.0
const SPRINT_MULT = 1.5
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.06
const JOY_SENSITIVITY = 1.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera
var rotation_helper
var dir = Vector3.ZERO
var flashlight

func _ready():
	camera = $rotation_helper/Camera3D
	rotation_helper = $rotation_helper
	flashlight = $rotation_helper/Camera3D/flashlight_player
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Alarm.play()
	await get_tree().create_timer(1).timeout
	$Alarm.stop()
	$AlarmClick.play()
	await get_tree().create_timer(1).timeout
	$OutOfBed.play()
	await get_tree().create_timer(5.5).timeout
	$DoorOpen.play()
	$ColorRect.queue_free()

func _input(event):
	
	# This section controls your player camera. Sensitivity can be changed.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation
		camera_rot.x = clampf(camera_rot.x, -1.4, 1.4)
		rotation_helper.rotation = camera_rot
	
	# Release/Grab Mouse for debugging. You can change or replace this.
	if Input.is_action_just_pressed("dev_release"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Flashlight toggle. Defaults to F on Keyboard.
	if event is InputEventKey or event is InputEventJoypadButton:
		if Input.is_action_just_pressed("flashlight"):
			if flashlight.is_visible_in_tree():
				flashlight.hide()
				$UIClick.play()
			else:
				flashlight.show()
				$UIClick.play()

func _process(delta):
	var x_power = Input.get_action_strength("look_right") + (Input.get_action_strength("look_left") * -1.0)
	var y_power = Input.get_action_strength("look_down") + (Input.get_action_strength("look_up") * -1.0)
		
	rotation_helper.rotate_x(deg_to_rad(y_power * JOY_SENSITIVITY * -1))
	self.rotate_y(deg_to_rad(x_power * JOY_SENSITIVITY * -1))

	var camera_rot = rotation_helper.rotation
	camera_rot.x = clampf(camera_rot.x, -1.4, 1.4)
	rotation_helper.rotation = camera_rot

var steps_active = false
var foot_sound = -1

func _physics_process(delta):
	
	var moving = false
	# Add the gravity. Pulls value from project settings.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# This just controls acceleration. Don't touch it.
	var accel
	if dir.dot(velocity) > 0:
		accel = ACCEL
		moving = true
	else:
		accel = DEACCEL
		moving = false
	
#	Logic for combining items:
#	1. Define combinable_items = {item_1, item_2}
#	2. Define requirements forcombination
#	3. Check if item_1 and item_2 are in combinable_items: return true if both items meet the requirements, false otherwise
#	4. If for_combination(item_1, item_2) is true: remove item_1 and item_2 from player's inventory
#	5a. True: add new combined_item to player's inventory
#	5b. False: return null or display an error message
#	6. Feedback: Indicate to the player the result of the combination process

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with a custom keymap depending on your control scheme. These strings default to the arrow keys layout.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * accel * delta
	if Input.is_key_pressed(KEY_SHIFT):
		direction = direction * SPRINT_MULT
	else:
		pass

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if (foot_sound == 0 and global_position.y <= 8) or (foot_sound == 1 and global_position.y <= 4) or (foot_sound == 2 and global_position.y > 4):
		$FootstepsAntislip.stop()
		$FootstepsWood.stop()
		$FootstepsMetal.stop()
		foot_sound = -1
		steps_active = false
		return
	
	if velocity.length() > 0:
		if not steps_active:
			if global_position.y > 8:
				$FootstepsWood.play()
				foot_sound = 0
			elif global_position.y > 4:
				$FootstepsAntislip.play()
				foot_sound = 1
			else:
				$FootstepsMetal.play()
				foot_sound = 2
			steps_active = true
	else:
		if steps_active:
			$FootstepsAntislip.stop()
			$FootstepsWood.stop()
			$FootstepsMetal.stop()
			steps_active = false
			foot_sound = -1

func kill():
	var h = head.instantiate()
	h.position = global_position
	h.position.y += 2
	# h.apply_force(Vector3(1, 1, 1))
	get_parent().add_child(h)
	$rotation_helper/Camera3D.current = false
