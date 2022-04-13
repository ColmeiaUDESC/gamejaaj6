extends KinematicBody2D

const CORTE_EMPURRAO := 100.0 # Se o modulo da _velocidade_empurrao for menor que CORTE_EMPURRAO, nao sera mais processado empurrao

export(float) var vida_maxima := 1.0
export(float) var purificacao_maxima := 1.0
export(float) var velocidade = 1000
export(float, 1.0, 100.0) var desaceleracao_empurrao = 3.0
export(float, 1.0, 100.0) var resistencia_empurrao = 1.0

var jogador = null
var direcao = Vector2.ZERO
var movimento = Vector2.ZERO
var vida: float
var purificacao: float = 0.0

var _velocidade_empurrao: Vector2 = Vector2()

signal neutralizado(foi_morto)
signal recebido_dano(dano, agressor, e_offensivo)
signal infligido_dano(dano, vitima)

func _ready():
	$GerenciadorEstados.iniciar(self)
	vida = vida_maxima
	$Sprite.max_purificao = purificacao_maxima
	$Sprite.purificacao = purificacao


func _physics_process(delta: float):
	$GerenciadorEstados.executar(delta)


func inflige_dano(dano: float, agressor: Node2D) -> void:
	if esta_neutralizado():
		return

	emit_signal("recebido_dano", dano, agressor, true)

	vida = max(0, vida - dano)
	$Sprite.executar_anim_dano()
	$SomDanoOffensivo.play()

	if esta_morto():
		emit_signal("neutralizado", true)
		queue_free()


func inflingir_empurrao(vel: Vector2) -> void:
	_velocidade_empurrao = vel / resistencia_empurrao


func purificar(dano: float, agressor: Node2D) -> void:
	if esta_neutralizado():
		return

	emit_signal("recebido_dano", dano, agressor, false)

	purificacao = min(purificacao_maxima, purificacao + dano)
	$Sprite.purificacao = purificacao
	$SomDanoPurificacao.play()
	$Sprite.emitir_particulas_purificacao()
	if esta_purificado():
		set_collision_layer_bit(2, false)
		set_collision_mask_bit(1, false)
		emit_signal("neutralizado", false)
		mudar_de_estado("Purificado")


func mudar_de_estado(novo_estado: String) -> void:
	if not esta_neutralizado():
		$GerenciadorEstados.mudar_estado(novo_estado)
	elif not esta_morto():
		$GerenciadorEstados.mudar_estado("Purificado")
	else:
		$GerenciadorEstados.mudar_estado("Parado")


func estado_atual() -> String:
	return $GerenciadorEstados.estado_atual


func esta_purificado() -> bool:
	return purificacao == purificacao_maxima


func esta_morto() -> bool:
	return vida == 0


func esta_neutralizado() -> bool:
	return esta_purificado() or esta_morto()


func animar_ataque(dir: Vector2) -> void:
	$Sprite.play("atacando")
	$Sprite.flip_h = dir.x >= 0

func _pegar_suffixo_anim_dir(dir: Vector2) -> String:
	var phi := dir.angle()

	if phi >= PI/4 - 0.1 and phi <= 3*PI/4 + 0.1:
		return "frente"
	elif phi <= -PI/4 + 0.1 and phi >= -3*PI/4 - 0.1:
		return "costas"

	return "lado"

func gerenciar_animacoes_movimento() -> void:
	if direcao.length() > 0:
		var sufixo := _pegar_suffixo_anim_dir(direcao)
		$Sprite.play("andando_" + sufixo)
		$Sprite.flip_h = direcao.x < 0 if sufixo == "lado" else false


func gerenciar_movimento(delta: float) -> void:
	_processar_empurrao(delta)
	movimento = (direcao * velocidade + _velocidade_empurrao) * delta
	movimento = move_and_slide(movimento)
	gerenciar_animacoes_movimento()


func _processar_empurrao(delta: float) -> void:
	if _velocidade_empurrao.length() > CORTE_EMPURRAO:
		_velocidade_empurrao = lerp(_velocidade_empurrao, Vector2.ZERO, desaceleracao_empurrao * delta)
	else:
		_velocidade_empurrao = Vector2.ZERO


func _ao_infligir_dano(_dano: int) -> void:
	emit_signal("infligido_dano")


func _on_Sprite_animation_finished():
	if $Sprite.animation == "atacando":
		$Sprite.play("andando")
