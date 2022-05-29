extends KinematicBody2D

const TRAUMA_AO_RECEBER_DANO := .5
const TRAUMA_AO_INFLIGIR_DANO := .2
const CORTE_EMPURRAO := 100.0 # Se o modulo da _velocidade_empurrao for menor que CORTE_EMPURRAO, nao sera mais processado empurrao

export(float) var tempo_iniciar_descarregamento_purificacao := .5 # Tempo que o jogador deve ficar caminhando para começar a descarregar o ataque de purificação após estiver completamente carregado
export(float) var tempo_carregar_ataque_purificacao := 1.0 # Tempo que leva para completamente carregar o ataque de purificação
export(float) var tempo_descarregar_ataque_purificacao := 1.0 # Tempo que leva para completamente descarregar o ataque de purificação
export(float) var dano_ofensivo: float = 1.0
export(float) var dano_purificacao: float = 1.0
export(PackedScene) var cena_projetil_purificacao: PackedScene
export(float) var velocidade := 50.0
export(float) var vida_por_purificacao := 1.0
export(float) var vida_max := 12.0
export(float) var forca_empurrao_offensivo = 5000.0
export(float, 1.0, 100.0) var desaceleracao_empurrao = 3.0
export(float, 1.0, 100.0) var resistencia_empurrao = 1.0

onready var tween_transicao := $TweenCamera
onready var player_animacao := $AnimationPlayer

var direcao = Vector2()
var movimento = Vector2()
var vida_atual := 0.0 setget set_vida
var depois_do_ataque = false
var _progresso_ataque_purificacao := 0.0
var _inimigos_ja_danificados := []
var _velocidade_empurrao: Vector2 = Vector2()
var _tempo_desfazer_ataque_purificacao := 0.0
var pureza := 0 setget set_pureza

signal morreu()
signal pureza_mudou(novo_valor)
signal recebido_dano(dano)
signal infligido_dano(dano, e_offensivo)

func _ready() -> void:
# warning-ignore:integer_division
	pureza = (Globais.PUREZA_MAXIMA - Globais.PUREZA_MINIMA) / 2
	$UI/HP.max_value = vida_max
	$UI/Pureza.definir_pureza(pureza)
	self.vida_atual = vida_max


func _process(delta: float) -> void:
	# Everything works like you're used to in a top-down game
	direcao = Vector2()

	if Input.is_action_pressed("andar_pra_cima"):
		direcao += Vector2(0, -1)

	elif Input.is_action_pressed("andar_pra_baixo"):
		direcao += Vector2(0, 1)

	if Input.is_action_pressed("andar_pra_esquerda"):
		direcao += Vector2(-1, 0)

	elif Input.is_action_pressed("andar_pra_direita"):
		direcao += Vector2(1, 0)

	_processar_empurrao(delta)
	movimento = (direcao.normalized() * velocidade + _velocidade_empurrao) * delta
	movimento = move_and_slide(movimento)

	_gerenciar_ataque_offensivo()
	_gerenciar_ataque_passivo(delta)
	_gerenciar_animacoes()


func inflige_dano(dano: float, _agressor = null) -> void:
	if depois_do_ataque or esta_morto():
		return

	emit_signal("recebido_dano", dano)
	vida_atual = clamp(vida_atual - dano, 0.0, vida_max)
	$Sprite.executar_anim_dano()
	$Camera2D.adicionar_trauma(TRAUMA_AO_RECEBER_DANO)

	if esta_morto():
		$AnimationPlayer.play("sumir")
		$UI/TelaGameOver.mostrar()
		emit_signal("morreu")
	else:
		intangivel()


func inflingir_empurrao(vel: Vector2) -> void:
	_velocidade_empurrao = vel / resistencia_empurrao


func incrementar_pureza(qnt: int) -> void:
# warning-ignore:narrowing_conversion
	self.pureza = clamp(pureza + qnt, Globais.PUREZA_MINIMA, Globais.PUREZA_MAXIMA)


func set_pureza(valor: int) -> void:
	pureza = valor
	$UI/Pureza.definir_pureza(pureza)
	emit_signal("pureza_mudou", pureza)


func intangivel():
	depois_do_ataque = true
	$Intangibilidade.start()
	$AnimationPlayer.play("intangibilidade")


func _on_Intangibilidade_timeout():
	depois_do_ataque = false
	$AnimationPlayer.play("default")


func transicionar_camera(nova_pos_global: Vector2) -> void:
	tween_transicao.interpolate_property($Camera2D, "global_position", global_position, nova_pos_global, 0.25)
	tween_transicao.start()
	yield(tween_transicao, "tween_completed")
	$Camera2D.position = Vector2.ZERO


func set_vida(valor: float) -> void:
	vida_atual = clamp(valor, 0, vida_max)


func esta_morto() -> bool:
	return vida_atual == 0


func _gerenciar_animacoes() -> void:
	if $Ataque.atacando:
		var dir_ataque: Vector2 = Vector2.RIGHT.rotated($Ataque.angulo_ataque)
		var sufixo := _pegar_suffixo_anim_dir(dir_ataque)
		$Sprite.play("atacando_" + sufixo)
		$Sprite.flip_h = dir_ataque.x < 0 if sufixo == "lado" else false
	else:
		if direcao.length() > 0:
			var sufixo := _pegar_suffixo_anim_dir(direcao)
			$Sprite.play("andando_" + sufixo)
			$Sprite.flip_h = direcao.x < 0 if sufixo == "lado" else false
		else:
			$Sprite.flip_h = false
			$Sprite.play("rezando" if Input.is_action_pressed("ataque_purificacao") else "parado")


func _gerenciar_ataque_offensivo() -> void:
	if $Ataque.atacando:
		for corpo in $Ataque.get_overlapping_areas():
			if not "personagem" in corpo:
				continue
			
			var inimigo = corpo.personagem
			
			if _inimigos_ja_danificados.has(inimigo):
				continue
			
			_connectar_eventos_inimigo(inimigo)
			inimigo.inflige_dano(dano_ofensivo, self)
			inimigo.inflingir_empurrao(global_position.direction_to(inimigo.global_position) * forca_empurrao_offensivo)
			_inimigos_ja_danificados.append(inimigo)

	if not Input.is_action_just_pressed("ataque_offensivo") or $Ataque.atacando:
		return

	var dir_jogador_mouse := global_position.direction_to(get_global_mouse_position())
	$Ataque.atacar(dir_jogador_mouse)
	_inimigos_ja_danificados.clear()


func _gerenciar_ataque_passivo(delta: float) -> void:
	if not Input.is_action_pressed("ataque_purificacao"):
		if _progresso_ataque_purificacao >= 1.0:
			_instanciar_projetil()
		_progresso_ataque_purificacao = 0.0
		_tempo_desfazer_ataque_purificacao = 0.0
	else:
		if direcao.length_squared() > 0.0:
			_tempo_desfazer_ataque_purificacao = clamp(_tempo_desfazer_ataque_purificacao - delta, 0.0, tempo_iniciar_descarregamento_purificacao)
			if not _tempo_desfazer_ataque_purificacao:
				_progresso_ataque_purificacao = clamp(_progresso_ataque_purificacao - delta / tempo_descarregar_ataque_purificacao, 0.0, 1.0)
		else:
			var ant := _progresso_ataque_purificacao
			_progresso_ataque_purificacao = clamp(_progresso_ataque_purificacao + delta / tempo_carregar_ataque_purificacao, 0.0, 1.0)
			if _progresso_ataque_purificacao >= 1:
				_tempo_desfazer_ataque_purificacao = tempo_iniciar_descarregamento_purificacao
				if ant < 1:
					$Sprite.emitir_particulas_purificacao()
	$Sprite.purificacao = _progresso_ataque_purificacao


func _instanciar_projetil() -> void:
	var dir_jogador_mouse := global_position.direction_to(get_global_mouse_position())
	var projetil := cena_projetil_purificacao.instance()

	projetil.direcao = dir_jogador_mouse
	projetil.dano = dano_purificacao
	projetil.position = position + $PosProjetil.position

	var _err = projetil.connect("acertou_inimigo", self, "_ao_projetil_acertar_inimigo", [], CONNECT_ONESHOT)

	if Globais.container_projeteis:
		Globais.container_projeteis.add_child(projetil)
	else:
		get_parent().add_child(projetil)


func _processar_empurrao(delta: float) -> void:
	if _velocidade_empurrao.length() > CORTE_EMPURRAO:
		_velocidade_empurrao = lerp(_velocidade_empurrao, Vector2.ZERO, desaceleracao_empurrao * delta)
	else:
		_velocidade_empurrao = Vector2.ZERO


func _connectar_eventos_inimigo(inimigo: Node2D) -> void:
	if not inimigo.is_connected("recebido_dano", self, "_ao_infligir_dano"):
		var _err = inimigo.connect("recebido_dano", self, "_ao_infligir_dano", [], CONNECT_ONESHOT)
	if not inimigo.is_connected("neutralizado", self, "_ao_neutralizar"):
		var _err = inimigo.connect("neutralizado", self, "_ao_neutralizar", [], CONNECT_ONESHOT)


func _ao_infligir_dano(dano: float, _agressor: Node2D, e_offensivo: bool) -> void:
	emit_signal("infligido_dano", dano, e_offensivo)
	incrementar_pureza(-1 if e_offensivo else 1)
	$Camera2D.adicionar_trauma(TRAUMA_AO_INFLIGIR_DANO)


func _ao_neutralizar(foi_morto: bool) -> void:
	if not foi_morto:
		self.vida_atual += vida_por_purificacao


func _ao_projetil_acertar_inimigo(inimigo: Node2D):
	_connectar_eventos_inimigo(inimigo)


func _on_Sprite_animation_finished():
	if $Sprite.animation == "atacando":
		$Sprite.play("andando")


func _pegar_suffixo_anim_dir(dir: Vector2) -> String:
	var phi := dir.angle()

	if phi >= PI/4 - 0.1 and phi <= 3*PI/4 + 0.1:
		return "frente"
	elif phi <= -PI/4 + 0.1 and phi >= -3*PI/4 - 0.1:
		return "costas"

	return "lado"
