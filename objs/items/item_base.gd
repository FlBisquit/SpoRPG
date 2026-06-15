extends Resource
class_name Item

@export var name: String
@export_enum("Spell", "Armor", "Loot", "Quest_item") var type: String
@export var inv_icon: Texture2D
@export var stack_amnt: int
@export var item_path: String
