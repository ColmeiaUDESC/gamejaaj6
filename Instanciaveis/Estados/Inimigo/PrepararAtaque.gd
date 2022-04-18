extends Estado

export var velocidade_pulo := 100.0
export var dano := 1
export var caminho_raycast: NodePath

onready var raycast: RayCast2D = get_node(caminho_raycast)
onready var timer: Timer = $Timer

var distancia_dano := 5.0
var sprite: AnimatedSprite
var dir_pulo = Vector2.ZERO
var movimento := Vector2.ZERO
var colidido := false

signal ataque_terminou

func ao_entrar() -> void:
	sprite = inimigo.get_node("Sprite")
	sprite.flip_h = abs(inimigo.position.direction_to(inimigo.jogador.position).angle()) > PI*.5
	sprite.play("carregando_ataque")
	sprite.connect("animation_finished", self, "_ao_animacao_terminar")
	inimigo.direcao = Vector2.ZERO
	colidido = false


func executar(delta: float) -> void:
	if not timer.is_stopped():
		movimento = (dir_pulo * velocidade_pulo) * delta
		movimento = inimigo.move_and_slide(movimento)
		raycast.cast_to = inimigo.global_position.direction_to(inimigo.jogador.global_position) * distancia_dano
		if raycast.get_collider() == inimigo.jogador and not colidido:
			colidido = true
			inimigo.jogador.inflige_dano(dano)


func ao_sair() -> void:
	if not sprite.is_connected("animation_finished", self, "_ao_animacao_terminar"):
		sprite.disconnect("animation_finished", self, "_ao_animacao_terminar")


func _ao_timer_finalizar():
	emit_signal("ataque_terminou")


func _ao_animacao_terminar() -> void:
	if sprite.animation == "carregando_ataque":
		var jogador = inimigo.jogador
		dir_pulo = inimigo.position.direction_to(inimigo.jogador.position)
		sprite.play("ataque_"+inimigo._pegar_suffixo_anim_dir(dir_pulo))
		timer.start()
		timer.connect("timeout", self, "_ao_timer_finalizar")
	elif "ataque" in sprite.animation:
		sprite.stop()
		sprite.frame = sprite.frames.get_frame_count(sprite.animation) - 1
