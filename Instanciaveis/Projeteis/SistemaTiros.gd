extends Node

const ERRO_IP_NULO := ":  node filho com nome %s não existe."
const ERRO_IP_TIPO_INVALIDO := ": node filho com nome %s não possui atributos 'projetil' e/ou 'dano'. Certifique-se que %s possui o script InfoProjetil."

onready var inimigo = owner

signal disparado

func atirar(nome_info_projetil: String, angulo_deslocamento_graus: float = 0.0, usar_pos_jogador: bool = false) -> void:
	var info_projetil := get_node(nome_info_projetil)
	
	if info_projetil == null:
		printerr(get_parent(), ERRO_IP_NULO % nome_info_projetil)
	if not "projetil" in info_projetil or not "dano" in info_projetil:
		printerr(get_path(), ERRO_IP_TIPO_INVALIDO % nome_info_projetil)
		return
	
	var angulo_rad := deg2rad(angulo_deslocamento_graus)
	if inimigo.jogador and usar_pos_jogador:
		angulo_rad += inimigo.global_position.direction_to(inimigo.jogador.global_position).angle()
	
	var projetil_instancia: Node2D = info_projetil.projetil.instance()
	projetil_instancia.direcao = Vector2.RIGHT.rotated(angulo_rad)
	projetil_instancia.dano = info_projetil.dano
	projetil_instancia.position = inimigo.position
	
	inimigo.get_parent().add_child(projetil_instancia)
	
	emit_signal("disparado")
