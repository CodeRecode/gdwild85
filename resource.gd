extends Resource
class_name ResourceCost

enum ResourceType {
	WOOD,
	STONE,
	THATCH,
	FOOD
}

@export var resource_required: ResourceType
@export var amount: int
