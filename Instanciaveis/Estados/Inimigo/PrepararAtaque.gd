extends Estado

export var distancia_pulo := 40.0
export var velocidade_pulo := 100.0
export var dano := 1

onready var raycast: RayCast2D = $RayCast2D

var distancia_dano := 1000.0
var sprite: AnimatedSprite
var progresso_pulo := distancia_pulo
var dir_pulo = Vector2.ZERO
var movimento := Vector2.ZERO
var colidido := false

signal ataque_terminou

func ao_entrar() -> void:
	sprite = inimigo.get_node("Sprite")
	sprite.flip_h = abs(inimigo.position.direction_to(inimigo.jogador.position).angle()) > PI*.5
	sprite.play("carregando_ataque")
	sprite.connect("animation_finished", self, "_ao_animacao_terminar")
	progresso_pulo = distancia_pulo
	inimigo.direcao = Vector2.ZERO
	colidido = false


func executar(delta: float) -> void:
	if progresso_pulo < distancia_pulo:
		movimento = (dir_pulo * velocidade_pulo) * delta
		movimento = inimigo.move_and_slide(movimento)
		progresso_pulo += movimento.length()
		raycast.cast_to = inimigo.global_position.direction_to(inimigo.jogador.global_position) * distancia_dano
		print(raycast.is_colliding())
		if raycast.get_collider() == inimigo.jogador and not colidido:
			print("sim")
			colidido = true
			inimigo.jogador.inflige_dano(dano)
		if progresso_pulo >= distancia_pulo:
			emit_signal("ataque_terminou")


func ao_sair() -> void:
	if not sprite.is_connected("animation_finished", self, "_ao_animacao_terminar"):
		sprite.disconnect("animation_finished", self, "_ao_animacao_terminar")


func _ao_animacao_terminar() -> void:
	if sprite.animation == "carregando_ataque":
		var jogador = inimigo.jogador
		dir_pulo = inimigo.position.direction_to(inimigo.jogador.position)
		sprite.play("ataque_"+inimigo._pegar_suffixo_anim_dir(dir_pulo))
		progresso_pulo = 0.0
	elif "ataque" in sprite.animation:
		sprite.stop()
		sprite.frame = sprite.frames.get_frame_count(sprite.animation) - 1
