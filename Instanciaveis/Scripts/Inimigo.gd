extends KinematicBody2D

export(float) var vida_maxima := 1.0
export(float) var purificacao_maxima := 1.0
export(float) var velocidade = 1000

var jogador = null
var direcao = Vector2.ZERO
var movimento = Vector2.ZERO
var vida: float
var purificacao: float = 0.0

signal neutralizado(foi_morto)
signal recebido_dano(dano, agressor, e_offensivo)
signal infligido_dano(dano, vitima)

func _ready():
	$GerenciadorEstados.iniciar(self)
	vida = vida_maxima
	$Sprite.max_purificao = purificacao_maxima
	$Sprite.purificacao = purificacao


func _physics_process(delta):
	$GerenciadorEstados.executar(delta)
	movimento = direcao * velocidade * delta
	movimento = move_and_slide(movimento)
	if $Sprite.animation != "atacando":
		$Sprite.flip_h = movimento.x >= 0
		$Sprite.play("andando" if movimento.length() > 0 else "parado")


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


func esta_purificado() -> bool:
	return purificacao == purificacao_maxima


func esta_morto() -> bool:
	return vida == 0


func esta_neutralizado() -> bool:
	return esta_purificado() or esta_morto()


func animar_ataque(dir: Vector2) -> void:
	$Sprite.play("atacando")
	$Sprite.flip_h = dir.x >= 0


func _ao_infligir_dano(_dano: int) -> void:
	emit_signal("infligido_dano")


func _on_Sprite_animation_finished():
	if $Sprite.animation == "atacando":
		$Sprite.play("andando")
