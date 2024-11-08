extends "res://entities/entity.gd"


@export var texture_object : Texture2D
var has_object := false


func collide_with(target_entity: Entity) -> void:
	if target_entity is EntityDB.EntityObject and !has_object:
		texture = texture_object
		has_object = true
