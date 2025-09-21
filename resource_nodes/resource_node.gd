extends StaticBody3D
class_name ResourceNode


@export_enum("WOOD", "STONE", "THATCH", "FOOD") var resource_type: int
@export var resource_amount: int
@export var node_health: int = 5

@export var model: Node3D

var original_pos: Vector3


func _ready() -> void:
	original_pos = model.position


func gather_resource(damage: int) -> Dictionary:
	node_health -= damage
	var resources_awared: Dictionary = {resource_type : 0}

	if node_health <= 0:
		resources_awared[resource_type] = resource_amount
		_remove_node()

	return resources_awared


func _remove_node() -> void:
	queue_free.call_deferred()


func shake() -> void:
	if resource_type != 3:
		await get_tree().create_timer(0.5).timeout
	else:
		await get_tree().create_timer(0.1).timeout

	var tween = get_tree().create_tween()
	model.position = original_pos


	var offset = Vector3(
		randf_range(-0.1, 0.1),
		randf_range(0, 0),
		randf_range(-0.1, 0.1)
	)
	tween.tween_property(model, "position", original_pos + offset, 0.05)
	tween.tween_property(model, "position", original_pos, 0.05)
