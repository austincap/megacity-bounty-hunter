extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 10.5
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
#	if (event is InputEventMouseButton):
#		print(event)
#		var collisionPoint = $RayCast3D.get_collision_point()
#		print(collisionPoint)
#		velocity.y = move_toward(collisionPoint.y, 0, SPEED)
#		velocity.x = move_toward(collisionPoint.x, 0, SPEED)
#		velocity.z = move_toward(collisionPoint.z, 0, SPEED)

func _physics_process(delta):
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_pressed("rightclick"):
		if $RayCast3D.is_colliding():
			if hookshotlatched:
				print("hookshotlatched")
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
					direction = global_position.direction_to(collisionPoint)
					velocity = direction * SPEED * 10.0
				else:
					direction = Vector3(0, 0, 0)
					velocity = direction * 0
					hookshotlatched = true
	else:
		print("hookshot released")
		
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
					velocity.y -= gravity * delta * 0.02
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.

		if direction:
			if gliding == true:
				print("gliding")
				velocity.x = direction.x * SPEED * 2.0
				velocity.z = direction.z * SPEED * 2.0
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
