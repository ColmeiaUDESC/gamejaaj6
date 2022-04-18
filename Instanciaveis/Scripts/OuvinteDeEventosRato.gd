extends Node

onready var inimigo = get_parent()

func _on_Visao_body_entered(body):
	if body.name == "Jogador" and not inimigo.estado_atual() == "AtaquePulo":
		inimigo.jogador = body
		inimigo.mudar_de_estado("Seguir")
		


func _on_Visao_body_exited(body):
	if body == inimigo.jogador and not inimigo.estado_atual() == "AtaquePulo":
		inimigo.mudar_de_estado("Aguardo")
		inimigo.jogador = null


func _on_Area_de_ataque_body_entered(body):
	if body == inimigo.jogador and not inimigo.estado_atual() == "AtaquePulo":
		inimigo.mudar_de_estado("AtaquePulo")


func _on_Area_de_ataque_body_exited(body):
	if body == inimigo.jogador and not inimigo.estado_atual() == "AtaquePulo":
		inimigo.mudar_de_estado("Seguir")


func _on_AtaquePulo_ataque_terminou():
	inimigo.mudar_de_estado("Seguir")
