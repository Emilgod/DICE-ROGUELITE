extends MarginContainer

@export var hp_label: Label
@export var sprite_rect: TextureRect
@export var name_label: Label

var character: Character

func setup(char: Character):
	character = char
	name_label.text = char.character_name
	update_hp()

func update_hp():
	hp_label.text = "HP: %d/%d" % [character.current_hp, character.max_hp]
