extends CharacterBody3D

const SPEED = 2
const JUMP_VELOCITY = 4.5

const RUNNING_SPEED = 4

var running = false
var is_locked = false

@onready var cameraMount := $camera_mount
@onready var animation_player = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $Visuals


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-deg_to_rad(event.relative.x * 0.1))
			visuals.rotate_y(deg_to_rad(event.relative.x * 0.1))
			cameraMount.rotate_x(-deg_to_rad(event.relative.y * 0.1))

func _physics_process(delta: float) -> void:
	var localSpeed := SPEED
	
	if !animation_player.is_playing():
		is_locked = false
	
	if Input.is_action_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true
		
	
	if Input.is_action_pressed("run"):
		localSpeed = RUNNING_SPEED
		running = true
	else:
		localSpeed = SPEED
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
		
		if !is_locked:
			visuals.look_at(position + direction)
		
		velocity.x = direction.x * localSpeed
		velocity.z = direction.z * localSpeed
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, localSpeed)
		velocity.z = move_toward(velocity.z, 0, localSpeed)

	if !is_locked:
		move_and_slide()
