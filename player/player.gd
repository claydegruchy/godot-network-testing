extends CharacterBody3D

var speed = 8.0
var mouse_sensitivity = 0.002
var direction = Vector3.ZERO

# Camera
@onready var camera: Camera3D = %Camera3D
# SpringArm3D
@onready var spring_arm = $SpringArm3D
# MultiplayerSynchronizer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.2
	

func _ready():
	# makes it so that other players know this this instance belongs to this player
	multiplayer_synchronizer.set_multiplayer_authority(str(name).to_int())
	# makes sur we use our own camera
	camera.current = multiplayer_synchronizer.is_multiplayer_authority()
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if not multiplayer_synchronizer.is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -60, 60)

func _physics_process(delta):
	if not multiplayer_synchronizer.is_multiplayer_authority():
		return
	direction = Vector3(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"),
		0,
		Input.get_action_strength("Forward") - Input.get_action_strength("Back")
	).normalized()

	var basis = global_transform.basis
	var forward = - basis.z
	var right = basis.x

	var move_dir = (right * direction.x + forward * direction.z).normalized()

	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed
	velocity.y += -gravity / 2 * delta
	move_and_slide()
