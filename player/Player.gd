extends CharacterBody3D

#var resource2 = load("res://dialogues/NPC1.dialogue")
var SPEED = 5.0
const JUMP_VELOCITY = 20.5
const LOOKAROUND_SPEED = 0.01
var gliding = false
var hookshotlatched = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var rot_x = 0
var rot_y = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x += -event.relative.x * LOOKAROUND_SPEED
		rot_y += -event.relative.y * LOOKAROUND_SPEED
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		print($RayCast3D.get_collision_point())
		get_tree().get_root().get_node("mc4/NavigationRegion3D/person").set_movement_target($RayCast3D.get_collision_point())
		print(get_tree().get_root().get_node("mc4/NavigationRegion3D/person/NavigationAgent3D").get_next_path_position())
		print(get_tree().get_root().get_node("mc4/NavigationRegion3D/person/NavigationAgent3D").get_final_position())
	if event is InputEventKey and event.pressed and event.keycode == KEY_E:
		for node in $Area3D.get_overlapping_bodies():
			if node.is_in_group("NPC"):
				print("NPC")
				var resource = DialogueManager.create_resource_from_text("~ title\nCharacter: Hello!")
				var dialogue_line = await DialogueManager.get_next_dialogue_line(resource, "title")
				DialogueManager.show_dialogue_balloon(resource, "title")
				#var resource2 = load("res://some_dialogue.dialogue")
				# then
				#var dialogue_line2 = await DialogueManager.get_next_dialogue_line(resource2, "this_is_a_node_title")
				#DialogueManager.show_dialogue_balloon(resource2, "this_is_a_node_title")


func _physics_process(delta):
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_pressed("rightclick"):
		print("hookshot held")
		if $RayCast3D.is_colliding():
			if hookshotlatched:
				print("hookshot latched")
				velocity.y -= 0 * delta
				direction = Vector3(0, 0, 0)
				axis_lock_linear_x = true
				axis_lock_linear_y = true
				axis_lock_linear_z = true
			else:
				if not is_on_ceiling() and not is_on_wall(): 
					var collisionPoint = $RayCast3D.get_collision_point()
					print(collisionPoint)
					#Unit vector pointing at the target position from the characters position
					if $RayCast3D.is_colliding():
						direction = global_position.direction_to(collisionPoint)
					else:
						direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
					velocity = direction * SPEED * 10.0
				else:
					direction = Vector3(0, 0, 0)
					velocity = direction * 0
					hookshotlatched = true
		else:
			print($RayCast3D.is_colliding())
			print("raycast not colliding")
			direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y -= gravity * delta
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		#print("hookshot released")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		hookshotlatched = false
		axis_lock_linear_x = false
		axis_lock_linear_y = false
		axis_lock_linear_z = false
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("space"):
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
			else:
				if Input.is_action_pressed("space"):
					gliding = true
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.

		if Input.is_action_pressed("shift"):
			SPEED = 15.0
		else:
			SPEED = 5.0
			
		if direction:
			if gliding == true:
				print("gliding")
				velocity.x = direction.x * SPEED * 8.0
				velocity.y -= gravity * delta * 0.02
				velocity.z = direction.z * SPEED * 8.0
				if Input.is_action_just_released("space"):
					print("not gliding")
					gliding = false
			else:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
				velocity.y -= gravity * delta
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()


func _on_area_3d_body_entered(body):
	if body:
		print("IS IN GROUP:")
		print(body.is_in_group("NPC"))
		print(body.get_name())
