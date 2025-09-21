extends CharacterBody3D
class_name Villager


@export var building: Building

@onready var collision: CollisionShape3D = $CollisionShape3D
@export var animation_player: AnimationPlayer

var player: Player = null

#@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
#@export var wander_radius: float = 3.0
#@export var wander_speed: float = 2.0
#@export var wander_wait: float = 3.0
#var wander_timer: float = 0.0
#@export var nav_region: NavigationRegion3D
#
func _ready() -> void:
	self.visible = false
	collision.disabled = true
	animation_player.play("Idle")
	##randomize()
#
#
func _physics_process(_delta: float) -> void:
	if building.building_mesh.visible == true:
		self.visible = true
		collision.disabled = false

	if player != null:
		self.look_at(player.global_position)
		animation_player.play("Wave")
	elif player == null:
		animation_player.play("Idle")

	##wander_timer -= delta
#
	#if wander_timer <= 0 or nav_agent.is_target_reached():
		#_pick_new_destination()
		#print(nav_agent.target_position)
#
	#var target_position = nav_agent.get_next_path_position()
	#var direction = target_position - global_position
	#direction.y = 0
#
	#if direction.length() > 0.1:
		#velocity = direction.normalized() * wander_speed
		##walk
	#else:
		#velocity = Vector3.ZERO
#
	#move_and_slide()


func _on_proximity_detector_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body


func _on_proximity_detector_body_exited(body: Node3D) -> void:
	if body is Player:
		player = null


#func _pick_new_destination() -> void:
	#wander_timer = wander_wait
#
	#var random_offset: Vector3 = Vector3(
		#randf_range(-wander_radius, wander_radius),
		#0,
		#randf_range(-wander_radius,wander_radius)
	#)
#
	#var destination = NavigationServer3D.map_get_closest_point(nav_region.get_navigation_map(), global_position + random_offset)
	#nav_agent.target_position = destination


func _on_player_all_buildings_complete() -> void:
	animation_player.play("Floss")
