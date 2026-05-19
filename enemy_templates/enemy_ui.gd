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

func set_next_action(action: String):
	action_label.text = "" + action






func _on_highlight_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		board.combat_manager.execute_targeted_action(enemy, true)
		update_hp()
