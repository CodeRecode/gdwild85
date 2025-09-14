extends StaticBody3D
class_name ResourceNode

enum ResourceType {
	WOOD,
	STONE,
	THATCH,
	FOOD
}

@export var resource_type: ResourceType
@export var resource_amount: int
@export var node_health: int = 5


func gather_resource(damage: int) -> Dictionary:
	node_health -= damage
	var resources_awared: Dictionary = {resource_type : 0}

	if node_health <= 0:
		resources_awared[resource_type] = resource_amount
		remove_node()

	return resources_awared


func remove_node() -> void:
	queue_free.call_deferred()
