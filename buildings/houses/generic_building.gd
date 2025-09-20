extends StaticBody3D
class_name Building


enum BuildingType {
	Woodcutter,
	StoneMason,
	Thatcher,
	FoodStorage,
	Cafe,
	GeneralStore,
	PlayerHome
}

@export var building_type: BuildingType
@export var build_cost: Array[ResourceCost] = []

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var building_mesh: Node3D = $building
@onready var plot_mesh: Node3D = $plot
@onready var tent_mesh: Node3D = $tent

@onready var recipe_board: MeshInstance3D = $RecipeBoard
@onready var logs_amount_label: Label = $SubViewport/Control/Panel/HBoxContainer/Logs/LogsAmount
@onready var stone_amount_label: Label = $SubViewport/Control/Panel/HBoxContainer/Stone/StoneAmount
@onready var thatch_amount_label: Label = $SubViewport/Control/Panel/HBoxContainer/Thatch/ThatchAmount
@onready var food_amount_label: Label = $SubViewport/Control/Panel/HBoxContainer/Food/FoodAmount


func _ready() -> void:
	building_mesh.visible = false
	recipe_board.visible = false

	logs_amount_label.text = "x" + str(build_cost[0].amount)
	stone_amount_label.text = "x" + str(build_cost[1].amount)
	thatch_amount_label.text = "x" + str(build_cost[2].amount)
	food_amount_label.text = "x" + str(build_cost[3].amount)

	if building_type == BuildingType.PlayerHome:
		plot_mesh.visible = false
		tent_mesh.visible = true


func check_can_build(player_inventory: Dictionary) -> bool:
	for cost in build_cost:
		if player_inventory.get(cost.resource_required, 0) < cost.amount:
			return false
	return true


func build() -> void:
	plot_mesh.visible = false
	tent_mesh.visible = false
	building_mesh.visible = true
