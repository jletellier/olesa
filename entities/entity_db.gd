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

const SceneMap := {
	Vector2i(1, 0): {
		"scene": preload("res://entities/lawa.tscn"),
	},
	Vector2i(0, 1): {
		"scene": preload("res://entities/jo.tscn"),
	},
	Vector2i(1, 1): {
		"scene": preload("res://entities/pali.tscn"),
	},
	Vector2i(2, 0): {
		"scene": preload("res://entities/object.tscn"),
	},
	Vector2i(3, 0): {
		"scene": preload("res://entities/surface.tscn"),
	},
	Vector2i(5, 0): {
		"scene": preload("res://entities/wall_cracked.tscn"),
	},
	Vector2i(6, 0): {
		"scene": preload("res://entities/door.tscn"),
	},
	Vector2i(7, 0): {
		"scene": preload("res://entities/container.tscn"),
		"data": { "has_tool": true },
	},
	Vector2i(7, 2): {
		"scene": preload("res://entities/container.tscn"),
	},
	Vector2i(5, 1): {
		"scene": preload("res://entities/mountain.tscn"),
	},
	Vector2i(0, 2): {
		"scene": preload("res://entities/construction.tscn"),
	},
}
