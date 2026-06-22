extends BaseBuffSpell

func _init() ->void:
	spell_name = "haste"

func on_activate() -> void:
	caster.apply_buff("speed", 1.5, 5.0)
