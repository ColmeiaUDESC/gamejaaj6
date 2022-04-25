extends Node

onready var inimigo = get_parent()
onready var area_ataque: Area2D = inimigo.get_node("Area_de_ataque")

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


func _on_AtaquePulo_pulo_finalizou():
	inimigo.mudar_de_estado("AtaquePulo" if inimigo.jogador in area_ataque.get_overlapping_bodies() else "Seguir")
