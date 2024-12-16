extends CharacterBody3D

@export var speed = 2
@export var acceleration = 10
var Global

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var target: Marker3D = $"../../../Target"


func _physics_process(delta: float) -> void:
	
	var direction = Vector3()
	
	nav.target_position = Global.target.global_position
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed , acceleration * delta)
	
	move_and_slide()
