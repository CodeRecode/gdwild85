extends CharacterBody3D
class_name Player

@onready var animalchar: Node3D = $animalchar
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var tool_node: BoneAttachment3D = $animalchar/Armature/Skeleton3D/ToolNode
@onready var axe: Node3D = $animalchar/Armature/Skeleton3D/ToolNode/axe
@onready var hammer: Node3D = $animalchar/Armature/Skeleton3D/ToolNode/hammer
@onready var sickle: Node3D = $animalchar/Armature/Skeleton3D/ToolNode/sickle

@onready var bubble: MeshInstance3D = $SubViewport/Control/Panel/Bubble
@onready var green_check: MeshInstance3D = $SubViewport/Control/Panel/Bubble/GreenCheck
@onready var red_x: MeshInstance3D = $SubViewport/Control/Panel/Bubble/RedX
@onready var bear_face: MeshInstance3D = $SubViewport/Control/Panel/Bubble/BearFace

@onready var logs_amount_label: Label = $HUD/MarginContainer/HBoxContainer/Logs/LogsAmount
@onready var stone_amount_label: Label = $HUD/MarginContainer/HBoxContainer/Stone/StoneAmount
@onready var thatch_amount_label: Label = $HUD/MarginContainer/HBoxContainer/Thatch/ThatchAmount
@onready var food_amount_label: Label = $HUD/MarginContainer/HBoxContainer/Food/FoodAmount

const GATHERING_ANIMS = ["Chop", "Chop_Bounce", "Gather"]
const BUILDING_ANIMS = ["Throw"]
const SPEED = 5.0

var running: bool = false
var walking: bool = false

var detected_resource_node: ResourceNode = null
var detected_building_node: Building = null
var inventory: Dictionary = {}

var houses_built: Dictionary = {}


func _ready() -> void:
	for type in ResourceCost.ResourceType.values():
		inventory[type] = 0

	for type in Building.BuildingType.values():
		houses_built[type] = 1


func _physics_process(_delta: float) -> void:
	_read_movement_input()
	_check_gather_resources()
	_check_build()
	move_and_slide()


func _read_movement_input() -> void:
	var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
	var current_animation = animation_state_machine.get_current_node()
	var is_gathering = current_animation in GATHERING_ANIMS
	var is_building = current_animation in BUILDING_ANIMS
	if is_gathering or is_building:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		return

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

	if should_run and input_dir.length() >= 0.2:
		running = true
		velocity.x = direction.x * SPEED * 2
		velocity.z = direction.z * SPEED * 2
	elif input_dir.length() >= 0.2:
		walking = true
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	bubble.global_position.x = global_position.x
	bubble.global_position.z = global_position.z


func _on_interactable_detector_body_entered(node: Node) -> void:
	if node is ResourceNode:
		detected_resource_node = node
		print("can gather")
	elif node is Building:
		detected_building_node = node


func _on_interactable_detector_body_exited(node: Node) -> void:
	if node == detected_resource_node:
		detected_resource_node = null
		print("cannot gather")

	if node == detected_building_node:
		detected_building_node = null
		bubble.visible = false


func _check_gather_resources() -> void:
	var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
	var is_gathering = animation_state_machine.get_current_node() in GATHERING_ANIMS
	tool_node.visible = is_gathering
	if is_gathering:
		return

	if detected_resource_node == null:
		return

	if Input.is_action_just_pressed("interact"):
		var damage: int = 10

		damage *= houses_built[Building.BuildingType.Cafe]
		damage *= houses_built[Building.BuildingType.GeneralStore]
		damage *= houses_built[Building.BuildingType.PlayerHome]

		match detected_resource_node.resource_type:
			ResourceCost.ResourceType.WOOD:
				damage *= houses_built[Building.BuildingType.Woodcutter]
				axe.visible = true
				animation_state_machine.start("Chop_Bounce")
			ResourceCost.ResourceType.STONE:
				damage *= houses_built[Building.BuildingType.StoneMason]
				hammer.visible = true
				animation_state_machine.start("Chop_Bounce")
			ResourceCost.ResourceType.THATCH:
				damage *= houses_built[Building.BuildingType.Thatcher]
				sickle.visible = true
				animation_state_machine.start("Chop")
			ResourceCost.ResourceType.FOOD:
				damage *= houses_built[Building.BuildingType.FoodStorage]
				animation_state_machine.start("Gather")

		await animation_tree.animation_finished

		var gathered_resources: Dictionary = detected_resource_node.gather_resource(damage)
		_add_resources_to_inventory(gathered_resources)
		axe.visible = false
		hammer.visible = false
		sickle.visible = false


func _add_resources_to_inventory(resources: Dictionary) -> void:
	for type in resources.keys():
		inventory[type] += resources[type]

	_update_hud_amounts()


func _check_build() -> void:
	if detected_building_node == null:
		_show_bubble(false, false, false, false, false, 0)
		return

	if detected_building_node.check_can_build(inventory):
		_show_bubble(false, true, true, false, false, 2)
	elif detected_building_node.building_mesh.visible == false:
		_show_bubble(false, true, false, true, false, 2)

		if Input.is_action_just_pressed("interact"):
			Input.start_joy_vibration(0, 0.3, 0.5, 0.2)

		return

	if detected_building_node.building_mesh.visible == true:
		return
	var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
	var is_building = animation_state_machine.get_current_node() in BUILDING_ANIMS
	if is_building:
		return

	if Input.is_action_just_pressed("interact"):
		animation_state_machine.start("Throw")
		await animation_tree.animation_finished

		detected_building_node.build()
		_remove_resources_from_inventory(detected_building_node.build_cost)
		_show_bubble(true, true, false, false, true, 2)

		match detected_building_node.building_type:
			Building.BuildingType.Woodcutter:
				houses_built[detected_building_node.building_type] = 3
			Building.BuildingType.StoneMason:
				houses_built[detected_building_node.building_type] = 3
			Building.BuildingType.Thatcher:
				houses_built[detected_building_node.building_type] = 3
			Building.BuildingType.FoodStorage:
				houses_built[detected_building_node.building_type] = 3
			Building.BuildingType.Cafe:
				houses_built[detected_building_node.building_type] = 2
			Building.BuildingType.GeneralStore:
				houses_built[detected_building_node.building_type] = 2
			Building.BuildingType.PlayerHome:
				houses_built[detected_building_node.building_type] = 1


func _remove_resources_from_inventory(resources: Array[ResourceCost]) -> void:
	for type in resources:
		inventory[type.resource_required] -= type.amount

	_update_hud_amounts()


func _update_hud_amounts() -> void:
	logs_amount_label.text = "x" + str(inventory[0])
	stone_amount_label.text = "x" + str(inventory[1])
	thatch_amount_label.text = "x" + str(inventory[2])
	food_amount_label.text = "x" + str(inventory[3])

func _show_bubble(override:bool, show: bool, check: bool, x: bool, face: bool, time: float) -> void:
	if bubble.visible and not override: return

	bubble.visible = show
	green_check.visible = false
	red_x.visible = false
	bear_face.visible = false

	if check: green_check.visible = show
	elif x: red_x.visible = show
	elif face: bear_face.visible = show

	await get_tree().create_timer(time).timeout
	bubble.visible = false
	green_check.visible = false
	red_x.visible = false
	bear_face.visible = false
