extends Object


const Lawa := preload("res://entities/lawa.gd")
const Jo := preload("res://entities/jo.gd")
const Pali := preload("res://entities/pali.gd")
const EntityObject := preload("res://entities/object.gd")
const Surface := preload("res://entities/surface.gd")
const WallCracked := preload("res://entities/wall_cracked.gd")
const Door := preload("res://entities/door.gd")
const EntityContainer := preload("res://entities/container.gd")
const Mountain := preload("res://entities/mountain.gd")
const Construction := preload("res://entities/construction.gd")

const Types: Array[Dictionary] = [
	{
		"name": &"lawa",
		"atlas_coords": Vector2i(1, 0),
		"scene": preload("res://entities/lawa.tscn"),
	},
	{ 
		"name": &"jo",
		"atlas_coords": Vector2i(0, 1),
		"scene": preload("res://entities/jo.tscn"),
	},
	{ 
		"name": &"pali",
		"atlas_coords": Vector2i(1, 1),
		"scene": preload("res://entities/pali.tscn"),
	},
	{ 
		"name": &"object",
		"atlas_coords": Vector2i(2, 0),
		"scene": preload("res://entities/object.tscn"),
	},
	{ 
		"name": &"surface",
		"atlas_coords": Vector2i(3, 0),
		"scene": preload("res://entities/surface.tscn"),
	},
	{ 
		"name": &"wall_cracked",
		"atlas_coords": Vector2i(5, 0),
		"scene": preload("res://entities/wall_cracked.tscn"),
	},
	{ 
		"name": &"door",
		"atlas_coords": Vector2i(6, 0),
		"scene": preload("res://entities/door.tscn"),
	},
	{ 
		"name": &"container",
		"atlas_coords": Vector2i(7, 2),
		"scene": preload("res://entities/container.tscn"),
		"variants": [
			{
				"atlas_coords": Vector2i(7, 0),
				"data": { "InventorySystem": { "item_type": "tool" } },
			}
		]
	},
	{ 
		"name": &"mountain",
		"atlas_coords": Vector2i(5, 1),
		"scene": preload("res://entities/mountain.tscn"),
	},
	{ 
		"name": &"construction",
		"atlas_coords": Vector2i(0, 2),
		"scene": preload("res://entities/construction.tscn"),
	},
]

static var _name_map := {} # Typing: Dictionary[StringName, Dictionary]
static var _atlas_coords_map := {} # Typing: Dictionary[Vector2i, Dictionary]


static func _static_init():
	for type in Types:
		var name: StringName = type["name"]
		_name_map[name] = type
		
		var atlas_coords: Vector2i = type["atlas_coords"]
		_atlas_coords_map[atlas_coords] = type
		
		var variants: Array = type.get("variants", [])
		for variant in variants:
			var variant_atlas_coords: Vector2i = variant["atlas_coords"]
			var variant_data: Dictionary = variant["data"]
			var variant_type := type.duplicate()
			variant_type.erase("variants")
			variant_type["atlas_coords"] = variant_atlas_coords
			variant_type["data"] = variant_data
			_atlas_coords_map[variant_atlas_coords] = variant_type


static func get_by_atlas_name(name: StringName) -> Dictionary:
	return _name_map.get(name, {})


static func get_by_atlas_coords(atlas_coords: Vector2i) -> Dictionary:
	return _atlas_coords_map.get(atlas_coords, {})
