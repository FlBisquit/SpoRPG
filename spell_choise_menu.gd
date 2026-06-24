#@tool
extends Control

signal spell_chosen(spell)

const SPRITE_SIZE = Vector2(32,32)

var player

@export var bkg_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var line_width: int = 5

var buttons = []
var options: Array = []
var selection:int = 0

func Close():
	hide()
	print(options[selection])
	return options[selection]
func init(p) -> void:
	player = p
	if not player.equipped_spells_changed.is_connected(_on_spells_changed):
		player.equipped_spells_changed.connect(_on_spells_changed)
	_on_spells_changed(player.equipped_spells)
func _on_spells_changed(spells: Array) -> void:
	options = spells.duplicate()
	_rebuild_buttons()
	queue_redraw()
	
func _rebuild_buttons() -> void:
	for b in buttons:
		b.queue_free()
	buttons.clear()
	if options.is_empty():
		return
	var radius_mid = (inner_radius + outer_radius) / 2.0
	var angle_per_option = TAU / options.size()
	var cell_height = outer_radius - inner_radius
	var cell_width = radius_mid * angle_per_option
		
	for i in range(options.size()):
		var mid_rads = TAU * (i + 0.5) / options.size()
		var draw_pos = radius_mid * Vector2.from_angle(mid_rads)
		
		var spell_btn = Button.new()
		spell_btn.text = options[i]
		spell_btn.clip_text = true
		spell_btn.custom_minimum_size = Vector2(100, 100)
		add_child(spell_btn)
		spell_btn.size = Vector2(100, 100)
		if options.size() == 1:
			spell_btn.position = Vector2(- spell_btn.size / 2.0)
		else:
			spell_btn.position = draw_pos - spell_btn.size / 2.0
		spell_btn.pressed.connect(_on_button_pressed.bind(i))
		buttons.append(spell_btn)

func _draw() -> void:
	draw_circle(Vector2.ZERO, outer_radius, bkg_color)
	if options.size() < 1:
		return
	elif options.size() == 1:
		return
	else:
		var angle_per_option = TAU / options.size()
		for i in range(options.size()):
			var start_rads = angle_per_option * i
			var end_rads = angle_per_option * (i + 1)
			if selection == i:
				var points_per_arc = 32
				var points_inner = PackedVector2Array()
				var points_outer = PackedVector2Array()
				for j in range(points_per_arc + 1):
					var angle = start_rads + (end_rads - start_rads) * j / float(points_per_arc)
					points_inner.append(inner_radius * Vector2.from_angle(angle))
					points_outer.append(outer_radius * Vector2.from_angle(angle))
				points_outer.reverse()
				draw_polygon(points_inner + points_outer, PackedColorArray([highlight_color]))
			var point = Vector2.from_angle(start_rads)
			draw_line(point * inner_radius, point * outer_radius, line_color, line_width, true)
func _on_button_pressed(i: int) -> void:
	selection = i
	var spell = options[i]
	spell_chosen.emit(spell)
	  
func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	if mouse_radius < inner_radius:
		selection = 0
	else:
		var count = len(options)
		if count > 0:
			var mouse_rads = fposmod(mouse_pos.angle(), TAU)
			selection = floori((mouse_rads / TAU) * count) % count
	queue_redraw()
