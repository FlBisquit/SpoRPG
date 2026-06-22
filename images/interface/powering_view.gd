extends Control
var player
var chosen_upgrade = null

@onready var skill_point_counter: Label = $skill_point_counter
@onready var up_list: Control = $up_list

func _ready() -> void:
	player = get_parent().get_parent().get_parent()
	skill_point_counter.text = str(player.current_skill_points)
	for button in up_list.get_children():
		button.toggled.connect(_on_upgrade_toggled.bind(button))

func _on_upgrade_toggled(pressed: bool, button) -> void:
	if pressed:
		if chosen_upgrade != null:
			chosen_upgrade.button_pressed = false
		chosen_upgrade = button
	else:
		chosen_upgrade = null

func _on_accept_btn_pressed() -> void:
	if chosen_upgrade == null:
		return
	if player.current_skill_points < chosen_upgrade.cost:
		return
	player.current_skill_points -= chosen_upgrade.cost
	player.apply_upgrade(chosen_upgrade.stat, chosen_upgrade.value)
	skill_point_counter.text = str(player.current_skill_points)
	chosen_upgrade.button_pressed = false
	chosen_upgrade = null
func _process(delta: float) -> void:
	skill_point_counter.text = str(player.current_skill_points)
