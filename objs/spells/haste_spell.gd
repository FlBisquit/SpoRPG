extends BaseBuffSpell

func on_activate() -> void:
	caster.apply_buff("speed", 2.0, 5.0)
