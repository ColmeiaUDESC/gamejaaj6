extends Estado

export var velocidade_pulo := 100.0
export var dano := 1
export var distancia_raycast_dano := 10.0
export var caminho_raycast: NodePath

onready var raycast: RayCast2D = get_node(caminho_raycast)
onready var timer: Timer = $Timer

var sprite: AnimatedSprite
var dir_pulo = Vector2.ZERO
var movimento := Vector2.ZERO
var colidido := false

signal carregando_pulo
signal pulo_iniciou
signal pulo_finalizou

func ao_entrar() -> void:
	sprite = inimigo.sprite
	sprite.flip_h = abs(inimigo.position.direction_to(inimigo.jogador.position).angle()) > PI*.5
	sprite.play("carregando_ataque")
	sprite.connect("animation_finished", self, "_ao_animacao_terminar")
	emit_signal("carregando_pulo")
	inimigo.direcao = Vector2.ZERO
	colidido = false


func executar(delta: float) -> void:
	inimigo._processar_empurrao(delta)
	if not timer.is_stopped():
		movimento = (dir_pulo * velocidade_pulo) * delta
		movimento = inimigo.move_and_slide(movimento)
		var colisor = raycast.get_collider()
		if not colisor or not "personagem" in raycast.get_collider():
			return
		var jogador = colisor.personagem
		if jogador == inimigo.jogador and not colidido:
			colidido = true
			inimigo.jogador.inflige_dano(dano)


func ao_sair() -> void:
	if sprite.is_connected("animation_finished", self, "_ao_animacao_terminar"):
		sprite.disconnect("animation_finished", self, "_ao_animacao_terminar")
	if timer.is_connected("timeout", self, "_ao_timer_finalizar"):
		timer.disconnect("timeout", self, "_ao_timer_finalizar")
	inimigo.setar_colisao_jogador(true)


func _ao_timer_finalizar():
	emit_signal("pulo_finalizou")


func _ao_animacao_terminar() -> void:
	if sprite.animation == "carregando_ataque":
		dir_pulo = inimigo.position.direction_to(inimigo.jogador.position)
		
		sprite.play("ataque_"+inimigo._pegar_suffixo_anim_dir(dir_pulo))
		
		timer.start()
		timer.connect("timeout", self, "_ao_timer_finalizar")
		
		inimigo.setar_colisao_jogador(false)
		raycast.cast_to = dir_pulo * distancia_raycast_dano
		
		emit_signal("pulo_iniciou")
	elif "ataque" in sprite.animation:
		sprite.stop()
		sprite.frame = sprite.frames.get_frame_count(sprite.animation) - 1
