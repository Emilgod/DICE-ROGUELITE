extends RigidBody3D
@export var board: Node3D

var sides_data = []
var is_settled: bool = false
var settle_threshold: float = 0.1
var is_locked: bool = false
@onready var faces = [
	$face0,
	$face1,
	$face2,
	$face3,
	$face4,
	$face5
	]
@onready var mesh_instance = MeshInstance3D
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	update_mesh_colors()
	

func set_sides(data: Array) -> void:
	sides_data = data
	if is_node_ready():
		update_mesh_colors()
		


func get_effect_color(effects: Array) -> Color:
	# Priority: if multiple effects, pick the first one
	if effects.is_empty():
		return Color.GRAY  # Blank side
	
	match effects[0]:
		"attack":
			return Color.RED
		"shield":
			return Color.BLUE
		"poison":
			return Color.GREEN
		_:
			return Color.WHITE

func update_mesh_colors() -> void:
	if not is_node_ready():
		return
	
	for i in range(faces.size()):
		var face_mesh = faces[i]
		var material = StandardMaterial3D.new()
		var base_color = get_effect_color(sides_data[i]["effects"])
		
		material.albedo_color = base_color
		
		# Add glow/emission if locked
		if is_locked:
			material.emission_enabled = true
			material.emission = base_color
			material.emission_energy_multiplier = 2.0
		
		face_mesh.set_surface_override_material(0, material)
		
func _physics_process(delta: float) -> void:
	if is_locked:
		return
	if not is_settled:
		await get_tree().physics_frame
		if linear_velocity.length() < settle_threshold and angular_velocity.length() < settle_threshold:
			is_settled = true
			var top_face = get_top_face()
			var face_data = sides_data[top_face]
			print("Top face: ", top_face, " | Value: ", face_data["value"], " | Effects: ", face_data["effects"])

			
func get_top_face() -> int:
	
	var max_up = -1.0
	var top_face_index = 0
	
	# Check which face's normal points most upward
	for i in range(faces.size()):
		var face = faces[i]
		# Get the face's Y position to determine if it's pointing up
		var face_y = face.global_position.y
		
		# The face that's highest is the top
		if face_y > max_up:
			max_up = face_y
			top_face_index = i
	
	return top_face_index

func toggle_lock() -> void:
	is_locked = !is_locked
	update_mesh_colors()
	print("dice locked: ", is_locked)
	


func reset_and_reroll() -> void:
	is_settled = false
	position = Vector3(randf_range(0, 0.1), -1, randf_range(0, 0.1))
	apply_central_impulse(Vector3(randf_range(-10, 10), 0, randf_range(-10, 10)))
	apply_torque_impulse(Vector3(randf_range(-0.05, 0.05), randf_range(-0.05, 0.05), randf_range(-0.05, 0.05)))
