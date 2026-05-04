extends MarginContainer

@export var hp_label: Label
@export var sprite_rect: TextureRect
@export var name_label: Label
@export var ability_button: Button

var character: Character

func setup(char: Character):
	character = char
	name_label.text = char.character_name
	if char.ability:
		ability_button.text = char.ability.name
		ability_button.tooltip_text = char.ability.description
		if char.ability.ability_type == "passive":
			ability_button.disabled = true
	update_hp()

func update_hp():
	hp_label.text = "HP: %d/%d" % [character.current_hp, character.max_hp]
