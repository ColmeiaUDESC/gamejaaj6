extends Panel

signal fade_finalizado

func _ready() -> void:
	get_stylebox("panel").bg_color = Color.black


func converter_para_fade_final() -> void:
	get_stylebox("panel").bg_color = Color.white


func fade_in() -> void:
	$AnimationPlayer.play("fade_in")


func fade_out() -> void:
	$AnimationPlayer.play_backwards("fade_in")


func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("fade_finalizado")
