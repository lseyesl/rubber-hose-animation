extends RayCast2D

@export var fallback_surface: Resource


func get_surface_profile() -> Resource:
	if is_inside_tree():
		force_raycast_update()
	var collider := get_collider()
	if collider != null and collider.has_meta("surface_profile"):
		var surface_profile = collider.get_meta("surface_profile")
		if surface_profile is Resource:
			return surface_profile
	return fallback_surface
