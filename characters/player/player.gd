extends CharacterBody3D
class_name Player

enum ResourceType {
	WOOD,
	STONE,
	THATCH,
	FOOD
}

@onready var animalchar: Node3D = $animalchar
@onready var animation_tree: AnimationTree = $AnimationTree

const SPEED = 5.0

var running: bool = false
var walking: bool = false

var detected_resource_node: ResourceNode = null
var inventory: Dictionary = {}


func _ready() -> void:
	for type in ResourceType.values():
		inventory[type] = 0


func _physics_process(delta: float) -> void:
	_read_movement_input()
	_check_gather_resources()
	move_and_slide()


func _read_movement_input() -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var input_v_axis: float = Input.get_axis("joystick_up", "joystick_down")
	var input_h_axis: float = Input.get_axis("joystick_left", "joystick_right")
	var input_axis: Vector2 = Vector2(input_h_axis, input_v_axis)

	if input_dir.length() < input_axis.length():
		input_dir = input_axis

	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if input_dir.length() >= 0.2:
		animalchar.look_at(animalchar.global_position - direction)

	var should_run = Input.is_action_pressed("run_modifier") or abs(input_h_axis) >= 0.7 or abs(input_v_axis) >= 0.7

	running = false
	walking = false
	#run for now
	if should_run and input_dir.length() >= 0.2:
		running = true
		velocity.x = direction.x * SPEED * 2
		velocity.z = direction.z * SPEED * 2
	#walk for now
	elif input_dir.length() >= 0.2:
		walking = true
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func _on_interactable_detector_body_entered(node: Node) -> void:
	if node is ResourceNode:
		detected_resource_node = node
		print("can gather")


func _on_interactable_detector_body_exited(node: Node) -> void:
	if node == detected_resource_node:
		detected_resource_node = null
		print("cannot gather")


func _check_gather_resources() -> void:
	if detected_resource_node == null:
		return

	if Input.is_action_just_pressed("interact"):
		var gathered_resources: Dictionary = detected_resource_node.gather_resource(1)
		_add_resources_to_inventory(gathered_resources)
		animation_tree["parameters/playback"].travel("Chop")


func _add_resources_to_inventory(resources: Dictionary) -> void:
	for type in resources.keys():
		inventory[type] += resources[type]
		print(inventory)
