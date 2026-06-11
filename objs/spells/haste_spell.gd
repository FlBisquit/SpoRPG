extends BaseBuffSpell

func _init() ->void:
	spell_name = "haste"

func on_activate() -> void:
	caster.apply_buff("speed", 2.0, 5.0)
