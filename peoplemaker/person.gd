extends CharacterBody3D

var resource2 = load("res://addons/dialogue_manager/NPC1.dialogue")
@export var SPEED: float = 14.0
var movement_target: Vector3
@onready var navigation_agent: NavigationAgent3D
var hp = 10

func _ready() -> void:
	movement_target = Vector3(0,10,0)
	#print(get_tree().get_root().get_node("mc4/NavigationRegion3D/person/NavigationAgent3D").get_name())
	#navigation_agent = get_tree().get_root().get_node("mc4/NavigationRegion3D/person/NavigationAgent3D")
	navigation_agent = $NavigationAgent3D
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
	if hp <= 0:
		self.queue_free()

func _on_velocity_computed(safe_velocity: Vector3):
	#print("VELOCITY COMPUTE")
	velocity = safe_velocity
	move_and_slide()

func talkfunction():
	DialogueManager.show_dialogue_balloon(resource2, "this_is_a_node_title")




func _on_area_3d_area_entered(area):
	area.get_name()
	print("DMG")
	self.get_node("Text").text = "OWCH!"
	if area.is_in_group('weapon'):
		self.get_node("Text").text = "OWCH!"
		self.hp -= 1

		
