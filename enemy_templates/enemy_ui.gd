extends MarginContainer

@export var name_label: Label
@export var health_label: Label
@export var texture_rect: TextureRect

var enemy: Enemy
# Called when the node enters the scene tree for the first time

func setup(enemy_obj: Enemy):
	enemy = enemy_obj
	name_label.text = enemy.name
	update_hp()

func update_hp():
	health_label.text = "%d/%d" % [enemy.current_hp, enemy.max_hp]
