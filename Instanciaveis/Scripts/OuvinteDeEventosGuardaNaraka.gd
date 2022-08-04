extends Node

const ESTADO_ATAQUE := "AtacarMelee"
const ESTADO_SEGUIR := "Seguir"
const ESTADO_MOVIMENTO_ALEATORIO := "Aguardo"

onready var inimigo = get_parent()
onready var area_ataque = inimigo.get_node("AreaAtacar")

var _esta_em_area_ataque := false



func _on_AreaSeguir_body_entered(body: Node) -> void:
	if body.name == "Jogador":
		inimigo.jogador = body
		if inimigo.estado_atual() != ESTADO_ATAQUE:
			inimigo.mudar_de_estado(ESTADO_SEGUIR)


func _on_AreaSeguir_body_exited(body: Node) -> void:
	if body.name == "Jogador":
		if inimigo.estado_atual() != ESTADO_ATAQUE:
			inimigo.mudar_de_estado(ESTADO_MOVIMENTO_ALEATORIO)
		inimigo.jogador = null


func _on_AtacarMelee_finalizado():
	var novo_estado := ESTADO_ATAQUE
	if inimigo.jogador == null:
		novo_estado = ESTADO_MOVIMENTO_ALEATORIO
	elif not _esta_em_area_ataque:
		novo_estado = ESTADO_SEGUIR
	inimigo.mudar_de_estado(novo_estado)


func _on_AreaAtacar_area_entered(_area: Area2D):
	_esta_em_area_ataque = true
	if inimigo.estado_atual() != ESTADO_ATAQUE:
		inimigo.mudar_de_estado(ESTADO_ATAQUE)


func _on_AreaAtacar_area_exited(_area: Area2D):
	_esta_em_area_ataque = false
