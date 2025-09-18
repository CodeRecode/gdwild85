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


func _ready() -> void:
	building_mesh.visible = false

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
