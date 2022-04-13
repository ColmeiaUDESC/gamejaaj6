class_name GerenciadorEstados
extends Node

export(String) var estado_inicial: String

var estado_atual: String = ""

func iniciar(inimigo) -> void:
	for filho in get_children():
		filho.inimigo = inimigo
	mudar_estado(estado_inicial)


func executar(delta: float) -> void:
	get_node(estado_atual).executar(delta)


func mudar_estado(novo_estado: String) -> void:
	if has_node(estado_atual):
		get_node(estado_atual).ao_sair()

	get_node(novo_estado).ao_entrar()
	estado_atual = novo_estado
