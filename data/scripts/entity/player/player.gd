extends CharacterBody3D



## Variables ##
@export var look_sensitivity : float = 0.006
@export var jump_velocity = 6.0
@export var auto_bhop = true ## Checks if automatic bhopping is enabled (wow!)


## Ground Movement Settings ##
@export var sprint_speed = 8.5
@export var walk_speed = 7.0
@export var ground_acceleration = 14.0
@export var ground_decel = 10.0
@export var ground_friction = 6.0

## Air Movement Settings ##
@export var air_cap = 0.85
@export var air_acceleration = 800.0
@export var air_movement_speed = 500.0


var wish_dir := Vector3.ZERO

## Crouch Settings ##
const CROUCH_TRANSLATE = 0.6
const CROUCH_JUMP_ADD = CROUCH_TRANSLATE * 0.9
var is_crouched := false

## Headbobbing ##
const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQ = 2.4
var headbob_time := 0.0



## Functions ##

func get_move_speed() -> float:
	if is_crouched:
		return walk_speed * 0.8
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed


func _ready():
	pass



## Mouse Movement ##
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _headbob_effect(delta):
	headbob_time += delta * self.velocity.length()
	%Camera3D.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQ * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQ) * HEADBOB_MOVE_AMOUNT,
		0
	)



func _process(delta: float) -> void:
	pass

## Air Physics ##
func _handle_air_physics(delta) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	## Air Strafing ##
	var current_air_speed_wish_dir = self.velocity.dot(wish_dir)
	var capped_speed = min((air_movement_speed * wish_dir).length(), air_cap)
	var add_speed_till_cap = capped_speed - current_air_speed_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_acceleration * air_movement_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir


## Crouching ##
@onready var _origin_capsule_height = %CollisionShape3D.shape.height
func _handle_crouch(delta) -> void:
	var was_crouched_last_frame = is_crouched
	if Input.is_action_pressed("crouch"):
		is_crouched = true
	elif is_crouched and not self.test_move(self.global_transform, Vector3(0,CROUCH_TRANSLATE,0)):
		is_crouched = false
	
	# Allows for Crouch-Jumping
	var translate_y_if_possible := 0.0
	if was_crouched_last_frame != is_crouched and not is_on_floor():
		translate_y_if_possible = CROUCH_JUMP_ADD if is_crouched else -CROUCH_JUMP_ADD
	#Making sure player doesnt get stuck in floor or on ceiling during C-Jumping
	if translate_y_if_possible != 0.0:
		var result = KinematicCollision3D.new()
		self.test_move(self.global_transform, Vector3(0,translate_y_if_possible,0), result)
		self.position.y += result.get_travel().y
	
	%Head.position = Vector3(0,(-CROUCH_TRANSLATE if is_crouched else 0),0)
	%CollisionShape3D.shape.height = _origin_capsule_height - CROUCH_TRANSLATE if is_crouched else _origin_capsule_height
	%CollisionShape3D.position.y = %CollisionShape3D.shape.height / 6 ## This assumes the CharacterBody is LEVEL with the floor.

## Ground Physics ##
func _handle_ground_physics(delta) -> void:
	var cur_speed_on_ground_wish_dir = self.velocity.dot(wish_dir)
	var add_grnd_speed_till_cap = get_move_speed() - cur_speed_on_ground_wish_dir
	if add_grnd_speed_till_cap > 0:
		var accel_ground_speed = ground_acceleration * delta * get_move_speed()
		accel_ground_speed = min(accel_ground_speed, add_grnd_speed_till_cap)
		self.velocity += accel_ground_speed * wish_dir
	
	
	## Apply Friction
	var control = max(self.velocity.length(), ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(self.velocity.length() - drop, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed
	
	
	_headbob_effect(delta)


func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "foward", "backwards").normalized()
	## Note: Depending on what direction the CharacterBody3D is facing, you may have to change a few settings.
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	
	_handle_crouch(delta)
	
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept") or (auto_bhop and Input.is_action_just_pressed("ui_accept")):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
		
	
	move_and_slide()
