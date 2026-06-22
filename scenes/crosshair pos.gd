extends TextureRect

func _ready():
	var screen = get_viewport().get_visible_rect().size
	position = screen * 0.5 - size * 0.5
	print("прицел центр: ", position + size * 0.5)
