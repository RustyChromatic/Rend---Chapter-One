extends Node3D

var mouse_mov
var sway_threshold = 5
var sway_lerp = 5

@export var sway_left : Vector3
@export var sway_right : Vector3
@export var sway_norm : Vector3


func input(event):
	if event is InputEventMouseMotion:
		mouse_mov = -event.relative.x


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_mov != null:
		if mouse_mov > sway_threshold:
			rotation = rotation.lerp(sway_left, sway_lerp * delta)
		elif mouse_mov < sway_threshold:
			rotation = rotation.lerp(sway_right, sway_lerp * delta)
		else:
			rotation = rotation.lerp(sway_norm, sway_lerp * delta)
