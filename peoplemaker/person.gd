extends CharacterBody3D

@export var SPEED: float = 14.0
var movement_target: Vector3
@onready var navigation_agent: NavigationAgent3D

func _ready() -> void:
	movement_target = Vector3(0,10,0)
	print(get_tree().get_root().get_node("mc4/NavigationRegion3D/person/NavigationAgent3D").get_name())
	navigation_agent = get_tree().get_root().get_node("mc4/NavigationRegion3D/person/NavigationAgent3D")
	navigation_agent.set_target_position(movement_target)
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * SPEED
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	#print("VELOCITY COMPUTE")
	velocity = safe_velocity
	move_and_slide()

