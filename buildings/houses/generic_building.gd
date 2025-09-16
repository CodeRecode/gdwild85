extends StaticBody3D
class_name Building


enum BuildingType {
	Woodcutter,
	StoneMason,
	Thatcher,
	FoodStorage,
	Cafe,
	GeneralStore
}

@export var build_cost: Array[ResourceCost] = []

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var building_mesh: Node3D = $building


func _ready() -> void:
	building_mesh.visible = false


func check_can_build(player_inventory: Dictionary) -> bool:
	for cost in build_cost:
		if player_inventory.get(cost.resource_required, 0) < cost.amount:
			return false
	return true


func build() -> void:
	building_mesh.visible = true
