extends Control

signal fireball
signal sparkle
func _ready() -> void:
	self.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("spell_menu") and self.visible == false:
		self.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("spell_menu") and self.visible == true: 
		self.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_fireball_pressed() -> void:
	fireball.emit()

func _on_button_pressed() -> void:
	sparkle.emit()
