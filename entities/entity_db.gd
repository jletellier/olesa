extends Object


const Jo := preload("res://entities/jo.gd")
const Lawa := preload("res://entities/lawa.gd")
const EntityObject := preload("res://entities/object.gd")
const Surface := preload("res://entities/surface.gd")
const WallCracked := preload("res://entities/wall_cracked.gd")
const Door := preload("res://entities/door.gd")
const EntityContainer := preload("res://entities/container.gd")

const SceneMap := {
	Vector2i(1, 0): preload("res://entities/lawa.tscn"),
	Vector2i(0, 1): preload("res://entities/jo.tscn"),
	Vector2i(2, 0): preload("res://entities/object.tscn"),
	Vector2i(3, 0): preload("res://entities/surface.tscn"),
	Vector2i(5, 0): preload("res://entities/wall_cracked.tscn"),
	Vector2i(6, 0): preload("res://entities/door.tscn"),
	Vector2i(7, 0): preload("res://entities/container.tscn"),
}
