extends Estado

onready var _timer_preparo_ataque : Timer = $PreparoAtaque

export (float) var forca_empurrao := 3000.0
export (float) var tempo_preparo_ataque := 0.0
export (NodePath) var caminho_ataque_melee: NodePath
export (int) var dano := 1

var _dir_ataque := Vector2.ZERO
var _ataque_melee : Area2D
var _personagens_atingidos := []

signal finalizado

func _ready():
	if caminho_ataque_melee.is_empty():
		printerr(get_path(), ": O atributo 'caminho_ataque_melee' não foi definido")


func ao_entrar() -> void:
	_dir_ataque = inimigo.global_position.direction_to(inimigo.jogador.global_position)
	_ataque_melee = get_node(caminho_ataque_melee)
	if _timer_preparo_ataque.wait_time > 0.0:
		inimigo.virar_sprite_para_dir(_dir_ataque)
		inimigo.sprite.play("preparando_ataque_%s" % inimigo._pegar_suffixo_anim_dir(_dir_ataque))
		_timer_preparo_ataque.start(tempo_preparo_ataque)
	else:
		atacar()


func executar(delta: float) -> void:
	inimigo._processar_empurrao(delta)
	_processar_colisao_ataque()


func _processar_colisao_ataque():
	if not _ataque_melee.atacando:
		return
	for area in _ataque_melee.get_overlapping_areas():
		var personagem = area.owner
		if personagem.name == "Jogador" and not personagem in _personagens_atingidos:
			_personagens_atingidos.append(personagem)
			inimigo.infligir_dano_a_personagem(personagem, dano, inimigo.global_position.direction_to(personagem.global_position) * forca_empurrao)


func ao_sair() -> void:
	_resetar_ataque()


func _resetar_ataque():
	_personagens_atingidos.clear()
	_timer_preparo_ataque.stop()
	if _ataque_melee.is_connected("ataque_finalizou", self, "_ao_ataque_melee_finalizar"):
		_ataque_melee.disconnect("ataque_finalizou", self, "_ao_ataque_melee_finalizar")


func atacar() -> void:
	_conectar_eventos_ataque()
	_ataque_melee.atacar(_dir_ataque)
	inimigo.sprite.play("ataque_%s" % inimigo._pegar_suffixo_anim_dir(_dir_ataque))


func _conectar_eventos_ataque() -> void:
	var _err := OK
	
	if not _ataque_melee.is_connected("ataque_finalizou", self, "_ao_ataque_melee_finalizar"):
		_err = _ataque_melee.connect("ataque_finalizou", self, "_ao_ataque_melee_finalizar")
	
	if _err:
		printerr(get_path(), ": Houve um erro ao conecar um evento. Código de erro: ", _err )


func _ao_ataque_melee_finalizar() -> void:
	_resetar_ataque()
	emit_signal("finalizado")
