extends Node

onready var inimigo = get_parent()

func _on_Visao_body_entered(body):
	if body.name == "Jogador":
		inimigo.jogador = body
		inimigo.mudar_de_estado("Fugir")


func _on_Visao_body_exited(body):
	if body.name == "Jogador":
		inimigo.mudar_de_estado("Aguardo")
		inimigo.jogador = null
