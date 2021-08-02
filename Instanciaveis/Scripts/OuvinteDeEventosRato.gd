extends Node


func _on_Visao_body_entered(body):
	if body.name == "Jogador":
		get_parent().jogador = body
		get_parent().mudar_de_estado("Seguir")


func _on_Visao_body_exited(body):
	if body == get_parent().jogador:
		get_parent().mudar_de_estado("Aguardo")
		get_parent().jogador = null


func _on_Area_de_ataque_body_entered(body):
	if body == get_parent().jogador:
		get_parent().mudar_de_estado("Atacar")


func _on_Area_de_ataque_body_exited(body):
	if body == get_parent().jogador:
		get_parent().mudar_de_estado("Seguir")
