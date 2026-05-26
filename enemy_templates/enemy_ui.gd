extends MarginContainer
@export var highlight: ColorRect
@export var board: Node3D

@export var name_label: Label
@export var health_label: Label
@export var texture_rect: TextureRect
@export var action_label: Label
var enemy: Enemy
# Called when the node enters the scene tree for the first time
func _process(delta: float) -> void:
	if board.action_targeting == "ENEMY_TARGETED" and not board.pending_action.is_empty():
		highlight.show()
	else:
		highlight.hide()

func setup(enemy_obj: Enemy):
	enemy = enemy_obj
	name_label.text = enemy.character_name
	update_hp()
	
func update_hp():
	health_label.text = "%d/%d" % [enemy.current_hp, enemy.max_hp]
	
	# Check if enemy died
	if enemy.current_hp <= 0:
		var enemy_index = board.current_enemies.find(enemy)
		if enemy_index != -1:
			board.current_enemies.remove_at(enemy_index)
			board.update_enemy_positions()
		
		# Check if all enemies are dead
		if board.current_enemies.is_empty():
			print("=== VICTORY ===")
			board.victory()
		
		queue_free()
func set_next_action(action: String):
	action_label.text = "" + action




func color_action_label(target_character: Character):
	action_label.add_theme_color_override("font_color", target_character.class_color)

func _on_highlight_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		board.combat_manager.execute_targeted_action(enemy, true)
		update_hp()

func show_enemy_info():
	print("Enemy: %s" % enemy.character_name)
	print("HP: %d/%d" % [enemy.current_hp, enemy.max_hp])
	print("Possible attacks:")
	
	for side in enemy.dice.sides:
		if not side["effects"].is_empty():
			print("  - %s (damage: %d)" % [side["effects"], side["value"]])


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if board.pending_action.is_empty():
			show_enemy_info()
