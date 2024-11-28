extends ColorRect


const PALETTES := [
	preload("res://assets/palettes/1bit_plus.png"),
	preload("res://assets/palettes/chocolate_ichor.png"),
	preload("res://assets/palettes/1bit_styx.png"),
	preload("res://assets/palettes/rusty_steam.png"),
	preload("res://assets/palettes/cvd3.png"),
]

var _palette_id := 0:
	set = _set_palette_id


func _ready() -> void:
	_palette_id = _palette_id


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_palette_swap"):
		_palette_id = _palette_id + 1


func _set_palette_id(value: int) -> void:
	_palette_id = value % PALETTES.size()
	
	var shader_material := material as ShaderMaterial
	shader_material.set_shader_parameter("palette_swap", PALETTES[_palette_id])
