extends "res://entities/entity.gd"


const EntitySuccess := preload("res://ui/hints/entity_success.gd")

@export var texture_object: Texture2D

var has_object := false

@onready var _hint_success := $"HintSuccess" as EntitySuccess
@onready var _audio_finish := $"AudioFinish" as AudioStreamPlayer


func collide_with(target_entity: Entity) -> void:
	# FIXME: Surface should not move when object is pushed onto it
	
	if target_entity is EntityDB.EntityObject and !has_object:
		_sprite.texture = texture_object
		has_object = true
		_hint_success.animate()
		_audio_finish.play()
