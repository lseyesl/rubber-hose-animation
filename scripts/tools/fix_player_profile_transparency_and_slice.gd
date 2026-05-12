extends SceneTree

const PROFILE_PATH := "res://docs/assets/player_profile.png"
const PARTS_DIR := "res://resources/player/parts"
const BACKGROUND_ALPHA := 0.0

const SLICES := {
	"torso_front.png": Rect2i(242, 294, 149, 264),
	"torso_side.png": Rect2i(676, 290, 116, 278),
	"head_front.png": Rect2i(197, 49, 239, 268),
	"head_side.png": Rect2i(618, 59, 245, 261),
	"eye_left.png": Rect2i(284, 158, 39, 76),
	"eye_right.png": Rect2i(341, 158, 34, 73),
	"brow_left.png": Rect2i(273, 142, 52, 27),
	"brow_right.png": Rect2i(325, 142, 52, 27),
	"mouth.png": Rect2i(283, 254, 78, 66),
	"arm_front.png": Rect2i(151, 299, 108, 176),
	"hand_front.png": Rect2i(141, 439, 97, 103),
	"leg_front.png": Rect2i(238, 555, 62, 76),
	"boot_front.png": Rect2i(176, 601, 125, 113),
}


func _initialize() -> void:
	var profile_image := Image.load_from_file(PROFILE_PATH)
	if profile_image == null:
		printerr("Failed to load %s" % PROFILE_PATH)
		quit(1)
		return

	profile_image.convert(Image.FORMAT_RGBA8)
	_make_edge_checkerboard_transparent(profile_image)
	var profile_error := profile_image.save_png(PROFILE_PATH)
	if profile_error != OK:
		printerr("Failed to save %s: %s" % [PROFILE_PATH, profile_error])
		quit(1)
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PARTS_DIR))
	for file_name: String in SLICES.keys():
		var part_image := Image.create_empty(SLICES[file_name].size.x, SLICES[file_name].size.y, false, Image.FORMAT_RGBA8)
		part_image.blit_rect(profile_image, SLICES[file_name], Vector2i.ZERO)
		var part_error := part_image.save_png("%s/%s" % [PARTS_DIR, file_name])
		if part_error != OK:
			printerr("Failed to save %s/%s: %s" % [PARTS_DIR, file_name, part_error])
			quit(1)
			return

	print("Fixed player profile transparency and regenerated %d player part slices" % SLICES.size())
	quit(0)


func _make_edge_checkerboard_transparent(image: Image) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var visited: PackedByteArray = []
	visited.resize(width * height)

	var queue: Array[Vector2i] = []
	for x in width:
		_enqueue_background_pixel(image, visited, queue, Vector2i(x, 0), width)
		_enqueue_background_pixel(image, visited, queue, Vector2i(x, height - 1), width)
	for y in height:
		_enqueue_background_pixel(image, visited, queue, Vector2i(0, y), width)
		_enqueue_background_pixel(image, visited, queue, Vector2i(width - 1, y), width)

	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		var transparent := image.get_pixelv(current)
		transparent.a = BACKGROUND_ALPHA
		image.set_pixelv(current, transparent)

		_enqueue_background_pixel(image, visited, queue, current + Vector2i.LEFT, width)
		_enqueue_background_pixel(image, visited, queue, current + Vector2i.RIGHT, width)
		_enqueue_background_pixel(image, visited, queue, current + Vector2i.UP, width)
		_enqueue_background_pixel(image, visited, queue, current + Vector2i.DOWN, width)


func _enqueue_background_pixel(image: Image, visited: PackedByteArray, queue: Array[Vector2i], point: Vector2i, width: int) -> void:
	if point.x < 0 or point.y < 0 or point.x >= width or point.y >= image.get_height():
		return
	var index := point.y * width + point.x
	if visited[index] != 0:
		return
	visited[index] = 1
	if _is_fake_transparency_pixel(image.get_pixelv(point)):
		queue.append(point)


func _is_fake_transparency_pixel(color: Color) -> bool:
	if color.a < 0.99:
		return true
	var max_channel: float = maxf(color.r, maxf(color.g, color.b))
	var min_channel: float = minf(color.r, minf(color.g, color.b))
	return min_channel > 0.82 and max_channel - min_channel < 0.04
