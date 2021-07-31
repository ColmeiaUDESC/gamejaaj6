extends Panel


func mostrar() -> void:
	show()
	$AnimationPlayer.play("aparecer")


func _on_BotaoReencarnar_pressed():
	if not $AnimationPlayer.is_playing():
		var _err = get_tree().change_scene("res://Cenas/Jogo.tscn")


func _on_BotaoVoltar_pressed():
	if not $AnimationPlayer.is_playing():
		var _err = get_tree().change_scene("res://Cenas/MenuPrincipal.tscn")
