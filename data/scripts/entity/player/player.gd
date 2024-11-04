extends CharacterBody3D



## Head Bob Variables ##
const bob_freq = 2.0
const bob_amp = 0.08
var t_bob = 0.0

## Onready Variables ##
@onready var head = $head
@onready var aimcast = $head/Camera3D/AimCast
@onready var hand = $head/Hand
@onready var handloc = $head/HandLoc
@onready var muzzle = $"head/Camera3D/Hand/Colt Python/muzzle"
@onready var damage = 12

var direction = Vector3()

@export var SPEED = 10
const JUMP_VELOCITY = 4.5

const mouse_sense = 0.25

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y =  sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

## Camera
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -89, 89)
		

	

	if Input.is_action_just_pressed("fire"):
		if aimcast.is_colliding():
			var bullet = get_world_3d().direct_space_state
			var collision = bullet.intersect_ray(muzzle.transform.origin)
			
			if collision:
				var target = collision.collider
				
				if target.is_in_group("Enemy"):
					print("hit enemy")
					target.health -= damage

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		direction = Vector3()
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "foward", "backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		

## Head Bobbing ##
	t_bob += delta * velocity.length() * float(is_on_floor())
	head.transform.origin = _headbob(t_bob)
	
	
	
	
	move_and_slide()
