extends "res://entities/entity.gd"


@export var texture_object: Texture2D

var has_object := false

@onready var _audio_finish := $"AudioFinish" as AudioStreamPlayer


func collide_with(target_entity: Entity) -> void:
	if target_entity is EntityDB.EntityObject and !has_object:
		_sprite.texture = texture_object
		has_object = true
		_audio_finish.play()
