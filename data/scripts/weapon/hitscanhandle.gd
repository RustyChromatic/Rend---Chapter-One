extends Camera3D

var ray_range = 2000

func _Input(event):
	if event.is_action_pressed("fire"):
		Get_Camera_Collision()
		
func Get_Camera_Collision():
	var Center = get_viewport().get_size()/2
	
	var ray_origin = project_ray_origin(Center)
	var Ray_End = ray_origin + project_ray_normal(Center)*ray_range
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, Ray_End)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if not intersection.is_empty():
		print(intersection.colldier.name)
	else:
		print("nothing")
	
