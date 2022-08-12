extends Node

const ERRO_CIP_SEM_PROJETIL := ": node apontado por 'caminho_info_projetil' não possui atributo 'projetil'. Certifique-se que 'caminho_info_projetil' possui o script InfoProjetil."
const ERRO_CIP_SEM_DANO := ": node apontado por 'caminho_info_projetil' não possui atributo 'dano'. Certifique-se que 'caminho_info_projetil' possui o script InfoProjetil."

onready var inimigo = get_parent()

func atirar(caminho_info_projetil: NodePath, angulo_deslocamento_graus: float = 0.0, usar_pos_jogador: bool = false) -> void:
	var info_projetil := get_node(caminho_info_projetil)
	
	if not "projetil" in info_projetil:
		printerr(get_path(), ERRO_CIP_SEM_PROJETIL)
		return
	if not "dano" in info_projetil:
		printerr(get_path(), ERRO_CIP_SEM_DANO)
		return
	
	var angulo_rad := deg2rad(angulo_deslocamento_graus)
	if inimigo.jogador and usar_pos_jogador:
		angulo_rad += inimigo.global_position.direction_to(inimigo.jogador.global_position).angle()
	
	var projetil_instancia: Node2D = info_projetil.projetil.instance()
	projetil_instancia.direcao = Vector2.RIGHT.rotated(angulo_rad)
	projetil_instancia.dano = info_projetil.dano
	projetil_instancia.position = inimigo.position
	
	inimigo.get_parent().add_child(projetil_instancia)
