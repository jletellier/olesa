extends Object


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
		"name": &"jan",
		"atlas_coords": Vector2i(3, 1),
		"scene": preload("res://entities/jan.tscn"),
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
		"name": &"wall",
		"atlas_coords": Vector2i(-1, -1),
		"scene": preload("res://entities/wall.tscn"),
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
		"name": &"portal",
		"atlas_coords": Vector2i(4, 1),
		"scene": preload("res://entities/portal.tscn"),
	},
	{ 
		"name": &"sitelen_lawa",
		"atlas_coords": Vector2i(4, 5),
		"scene": preload("res://entities/sitelen_lawa.tscn"),
	},
	{ 
		"name": &"sitelen",
		"atlas_coords": Vector2i(0, 4),
		"scene": preload("res://entities/sitelen.tscn"),
		"variants": [
			{
				"atlas_coords": Vector2i(1, 5),
				"data": { "SitelenSystem": { "sitelen_id": 4, "shift_type": &"" } },
			},
			{
				"atlas_coords": Vector2i(2, 5),
				"data": { "SitelenSystem": { "sitelen_id": 5, "shift_type": &"wall" } },
			},
			{
				"atlas_coords": Vector2i(3, 5),
				"data": { "SitelenSystem": { "sitelen_id": 6, "shift_type": &"" } },
			},
			{
				"atlas_coords": Vector2i(5, 5),
				"data": { "SitelenSystem": { "sitelen_id": 8, "shift_type": &"wall" } },
			},
			{
				"atlas_coords": Vector2i(6, 5),
				"data": { "SitelenSystem": { "sitelen_id": 9, "shift_type": &"" } },
			},
			{
				"atlas_coords": Vector2i(7, 5),
				"data": { "SitelenSystem": { "sitelen_id": 10, "shift_type": &"wall" } },
			},
			{
				"atlas_coords": Vector2i(1, 6),
				"data": { "SitelenSystem": { "sitelen_id": 11, "shift_type": &"door" } },
			},
			{
				"atlas_coords": Vector2i(2, 6),
				"data": { "SitelenSystem": { "sitelen_id": 12, "shift_type": &"" } },
			},
			{
				"atlas_coords": Vector2i(3, 6),
				"data": { "SitelenSystem": { "sitelen_id": 13, "shift_type": &"" } },
			},
			{
				"atlas_coords": Vector2i(4, 6),
				"data": { "SitelenSystem": { "sitelen_id": 14, "shift_type": &"object" } },
			},
			{
				"atlas_coords": Vector2i(5, 6),
				"data": { "SitelenSystem": { "sitelen_id": 15, "shift_type": &"" } },
			},
			{
				"atlas_coords": Vector2i(6, 6),
				"data": { "SitelenSystem": { "sitelen_id": 16, "shift_type": &"" } },
			},
			{
				"atlas_coords": Vector2i(7, 6),
				"data": { "SitelenSystem": { "sitelen_id": 17, "shift_type": &"" } },
			},
			{
				"atlas_coords": Vector2i(2, 7),
				"data": { "SitelenSystem": { "sitelen_id": 18, "shift_type": &"" } },
			},
			{
				"atlas_coords": Vector2i(3, 7),
				"data": { "SitelenSystem": { "sitelen_id": 19, "shift_type": &"" } },
			},
		]
	},
	{ 
		"name": &"container",
		"atlas_coords": Vector2i(7, 2),
		"scene": preload("res://entities/container.tscn"),
		"variants": [
			{
				"atlas_coords": Vector2i(7, 0),
				"data": { "InventorySystem": { "item_type": "tool" } },
			},
			{
				"atlas_coords": Vector2i(7, 1),
				"data": { "InventorySystem": { "item_type": "stone" } },
			},
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
		"variants": [
			{
				"atlas_coords": Vector2i(0, 3),
				"data": {
					"ConstructibleSystem": {
						"processing_item_name": "stone",
						"target_item_name": "surface",
					},
				},
			},
			{
				"atlas_coords": Vector2i(1, 3),
				"data": {
					"ConstructibleSystem": {
						"processing_item_name": "stone",
						"target_item_name": "surface",
					},
					"InventorySystem": { "item_type": "stone" },
				},
			},
		]
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


static func get_by_name(name: StringName) -> Dictionary:
	return _name_map.get(name, {})


static func get_by_atlas_coords(atlas_coords: Vector2i) -> Dictionary:
	return _atlas_coords_map.get(atlas_coords, {})
