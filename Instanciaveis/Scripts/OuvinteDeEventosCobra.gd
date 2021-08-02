extends Node


func _on_Visao_body_entered(body):
	if body.name == "Jogador":
		get_parent().jogador = body


func _on_Visao_body_exited(body):
	if body == get_parent().jogador:
		get_parent().jogador = null
