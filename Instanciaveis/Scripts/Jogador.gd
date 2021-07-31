extends KinematicBody2D

const TRAUMA_AO_RECEBER_DANO := .5
const TRAUMA_AO_INFLIGIR_DANO := .2

export(float) var tempo_carregar_ataque_purificacao := 1.0
export(float) var tempo_descarregar_ataque_purificacao := 1.0
export(float) var dano_ofensivo: float = 1.0
export(float) var dano_purificacao: float = 1.0
export(PackedScene) var cena_projetil_purificacao: PackedScene
export(int) var pureza_maxima := 100
export(int) var pureza_minima := 0
export(float) var velocidade := 250.0

onready var tween_transicao := $TweenCamera
onready var player_animacao := $AnimationPlayer

var direcao = Vector2()
var movimento = Vector2()
var vida_max = 12.0
var vida_atual = 12.0
var regeneracao = 0.5
var depois_do_ataque = false
var _progresso_ataque_purificacao := 0.0
var _inimigos_ja_danificados := []
var pureza := 0

signal pureza_mudou(novo_valor)
signal recebido_dano(dano)
signal infligido_dano(dano, e_offensivo)

func _ready() -> void:
	pureza = (pureza_maxima - pureza_minima) / 2
	$UI/Pureza.min_value = pureza_minima
	$UI/Pureza.max_value = pureza_maxima
	$UI/Pureza.definir_pureza(pureza)


func _process(delta: float) -> void:
	# Everything works like you're used to in a top-down game
	direcao = Vector2()

	if Input.is_action_pressed("ui_up"):
		direcao += Vector2(0, -1)

	elif Input.is_action_pressed("ui_down"):
		direcao += Vector2(0, 1)

	if Input.is_action_pressed("ui_left"):
		direcao += Vector2(-1, 0)

	elif Input.is_action_pressed("ui_right"):
		direcao += Vector2(1, 0)

	movimento = direcao.normalized() * velocidade
	movimento = move_and_slide(movimento)

	# Debug
	if Input.is_action_just_pressed("ui_select"):
		vida_atual -= 1

	_gerenciar_ataque_offensivo()
	_gerenciar_ataque_passivo(delta)


func inflige_dano(dano: float) -> void:
	if not depois_do_ataque:
		emit_signal("recebido_dano", dano)
		vida_atual -= dano
		$Sprite.executar_anim_dano()
		$Camera2D.adicionar_trauma(TRAUMA_AO_RECEBER_DANO)
		intangivel()


func incrementar_pureza(qnt: int) -> void:
	pureza += qnt
	$UI/Pureza.definir_pureza(pureza)
	emit_signal("pureza_mudou", pureza)


func _on_Regen_HP_timeout():
	if (vida_atual + regeneracao) < vida_max:
		vida_atual += regeneracao

	elif (vida_atual + regeneracao) >= vida_max:
		vida_atual = vida_max


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


func _gerenciar_ataque_offensivo() -> void:
	if $Ataque/Sprite.playing:
		for corpo in $Ataque.get_overlapping_bodies():
			if corpo.has_method("inflige_dano") and not _inimigos_ja_danificados.has(corpo):
				if not corpo.is_connected("recebido_dano", self, "_ao_infligir_dano"):
					corpo.connect("recebido_dano", self, "_ao_infligir_dano", [], CONNECT_ONESHOT)
				corpo.inflige_dano(dano_ofensivo, self)
				_inimigos_ja_danificados.append(corpo)

	if not Input.is_action_just_pressed("ataque_offensivo") or $Ataque/Sprite.playing:
		return

	var dir_jogador_mouse := global_position.direction_to(get_global_mouse_position())
	$Ataque.atacar(dir_jogador_mouse)
	_inimigos_ja_danificados.clear()


func _gerenciar_ataque_passivo(delta: float) -> void:
	if not Input.is_action_pressed("ataque_purificacao"):
		if _progresso_ataque_purificacao >= 1.0:
			_instanciar_projetil()
		_progresso_ataque_purificacao = 0.0
	else:
		if direcao.length_squared() > 0.0:
			_progresso_ataque_purificacao = clamp(_progresso_ataque_purificacao - delta * tempo_descarregar_ataque_purificacao, 0.0, 1.0)
		else:
			var ant := _progresso_ataque_purificacao
			_progresso_ataque_purificacao = clamp(_progresso_ataque_purificacao + delta * tempo_descarregar_ataque_purificacao, 0.0, 1.0)
			if ant < 1 and _progresso_ataque_purificacao >= 1:
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


func _ao_infligir_dano(dano: float, _agressor: Node2D, e_offensivo: bool) -> void:
	emit_signal("infligido_dano", dano, e_offensivo)
	incrementar_pureza(-1 if e_offensivo else 1)
	$Camera2D.adicionar_trauma(TRAUMA_AO_INFLIGIR_DANO)


func _ao_projetil_acertar_inimigo(inimigo: Node2D):
	if not inimigo.is_connected("recebido_dano", self, "_ao_infligir_dano"):
		inimigo.connect("recebido_dano", self, "_ao_infligir_dano", [], CONNECT_ONESHOT)
