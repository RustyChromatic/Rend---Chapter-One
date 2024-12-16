extends Node3D

@onready var animation_player = $AnimationPlayer  # The AnimationPlayer node
@export var shoot_animation: String = "fire"  # Name of the animation to play on LMB

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("LMB"):  # Check if LMB is clicked
		play_shoot_animation()

# Function to play the shooting animation
func play_shoot_animation():
	# Ensure the animation is not already playing (optional check)
	if not animation_player.is_playing():
		animation_player.play(shoot_animation)  # Play the specified animation
