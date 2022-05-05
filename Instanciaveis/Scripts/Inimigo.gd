extends KinematicBody2D

const CORTE_EMPURRAO := 100.0 # Se o modulo da _velocidade_empurrao for menor que CORTE_EMPURRAO, nao sera mais processado empurrao

export(float) var vida_maxima := 1.0
export(float) var purificacao_maxima := 1.0
export(float) var velocidade := 1000
export(float, 1.0, 100.0) var desaceleracao_empurrao := 3.0
export(float, 1.0, 100.0) var resistencia_empurrao := 1.0

onready var sprite = $Sprite
onready var gerenciador_estados = $GerenciadorEstados
onready var som_atacar = $SomAtacar
onready var som_dano_ofensivo = $SomDanoOffensivo
onready var som_dano_purificacao = $SomDanoPurificacao 
onready var hitbox = $Hitbox

var jogador = null
var direcao := Vector2.ZERO
var movimento := Vector2.ZERO
var vida: float
var purificacao := 0.0

var BIT_CAMADA_COLIDE := 2
var BIT_CAMADA_ATRAVESSA := 6
var BIT_MASCARA_JOGADOR := 1

var _velocidade_empurrao := Vector2()

signal neutralizado(foi_morto)
signal recebido_dano(dano, agressor, e_offensivo)
signal infligido_dano(dano, vitima)

func _ready():
	$GerenciadorEstados.iniciar(self)
	vida = vida_maxima
	$Sprite.max_purificao = purificacao_maxima
	$Sprite.purificacao = purificacao


func _physics_process(delta: float):
	gerenciador_estados.executar(delta)


func inflige_dano(dano: float, agressor: Node2D) -> void:
	if esta_neutralizado():
		return

	emit_signal("recebido_dano", dano, agressor, true)

	vida = max(0, vida - dano)
	sprite.executar_anim_dano()
	som_dano_ofensivo.play()

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
	sprite.purificacao = purificacao
	som_dano_purificacao.play()
	sprite.emitir_particulas_purificacao()
	if esta_purificado():
		emit_signal("neutralizado", false)
		mudar_de_estado("Purificado")
		# Mudança de colisoes. Deve ocorrer apos mudar_de_estado("Purificado")
		# pois um estado pode sobrescrever as colisoes ao sair
		set_collision_layer_bit(BIT_CAMADA_COLIDE, false)
		set_collision_mask_bit(BIT_MASCARA_JOGADOR, false)
		hitbox.desativar()


func mudar_de_estado(novo_estado: String) -> void:
	if not esta_neutralizado():
		gerenciador_estados.mudar_estado(novo_estado)
	elif not esta_morto():
		gerenciador_estados.mudar_estado("Purificado")
	else:
		gerenciador_estados.mudar_estado("Parado")


func estado_atual() -> String:
	return gerenciador_estados.estado_atual


func esta_purificado() -> bool:
	return purificacao == purificacao_maxima


func esta_morto() -> bool:
	return vida == 0


func esta_neutralizado() -> bool:
	return esta_purificado() or esta_morto()


func _pegar_suffixo_anim_dir(dir: Vector2) -> String:
	if dir.length_squared() == 0.0:
		return "lado"
	
	var phi := dir.angle()

	if phi >= PI/4 - 0.1 and phi <= 3*PI/4 + 0.1:
		return "frente"
	elif phi <= -PI/4 + 0.1 and phi >= -3*PI/4 - 0.1:
		return "costas"

	return "lado"

func setar_colisao_jogador(colidir: bool):
	set_collision_layer_bit(BIT_CAMADA_COLIDE, bool(colidir))
	set_collision_layer_bit(BIT_CAMADA_ATRAVESSA, not bool(colidir))
	set_collision_mask_bit(BIT_MASCARA_JOGADOR, bool(colidir))

func gerenciar_animacoes_movimento() -> void:
	var sufixo := _pegar_suffixo_anim_dir(direcao)
	var em_movimento := direcao.length() > 0.0 and velocidade > 0.0
	sprite.flip_h = sufixo == "lado" and direcao.x < 0
	sprite.play("andando_" + sufixo if em_movimento else "parado")


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
