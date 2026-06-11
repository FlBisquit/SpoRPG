extends Control
var item_type = "spell"
var spell_slot_num: Vector2i
var spell : Dictionary
var mana_cost_text: String
var cooldown_text: String
@onready var manacost_text: Label = $manacost_text
@onready var cooldown: Label = $cooldown
