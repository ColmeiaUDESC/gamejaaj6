extends Node

export (float) var delay_remocao: float = 0.0

func _ready() -> void:
	if delay_remocao > 0.0:
		var _err = get_tree().create_timer(delay_remocao).connect("timeout", self, "queue_free")
