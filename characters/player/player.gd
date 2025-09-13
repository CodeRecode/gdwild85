extends CharacterBody3D
class_name Player

@onready var animation_player: AnimationPlayer = $animalchar/AnimationPlayer


const SPEED = 5.0

var running: bool = false
var can_interact: bool = false

func _ready() -> void:
	var idle_anim = animation_player.get_animation("Idle")
	idle_anim.loop_mode = Animation.LOOP_LINEAR
	animation_player.play("Idle")

func _physics_process(delta: float) -> void:
	_read_movement_input()
	move_and_slide()


func _read_movement_input() -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var input_v_axis: float = Input.get_axis("joystick_up", "joystick_down")
	var input_h_axis: float = Input.get_axis("joystick_left", "joystick_right")
	var input_axis: Vector2 = Vector2(input_h_axis, input_v_axis)

	if input_dir.length() < input_axis.length():
		input_dir = input_axis

	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if Input.is_action_pressed("run_modifier") or abs(input_h_axis) >= 0.7 or abs(input_v_axis) >= 0.7:
		running = true
	else:
		running = false

	#run for now
	if running and input_dir.length() >= 0.2:
		velocity.x = direction.x * SPEED * 2
		velocity.z = direction.z * SPEED * 2
	#walk for now
	elif input_dir.length() >= 0.2:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func _on_interactable_detector_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	print("detected")
