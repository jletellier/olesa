extends "res://entities/entity.gd"


@onready var _audio_destroy := $"AudioDestroy" as AudioStreamPlayer


func collide_with(target_entity: Entity) -> void:
	if target_entity is EntityDB.EntityObject:
		# Move audio player, otherwise it gets freed as well
		_audio_destroy.reparent(get_parent())
		_audio_destroy.play()
		
		map.remove_entity(self)
