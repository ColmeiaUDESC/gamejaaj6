extends Panel



signal fade_finalizado

func fade_in() -> void:
	$AnimationPlayer.play("fade_in")


func fade_out() -> void:
	$AnimationPlayer.play_backwards("fade_in")


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("fade_finalizado")
