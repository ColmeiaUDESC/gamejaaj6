extends Estado

export var distancia_pulo := 40.0
export var velocidade_pulo := 100.0
export var indice_frame_pausa: int = 3
var sprite: AnimatedSprite
var progresso_pulo := distancia_pulo
var dir_pulo = Vector2.ZERO
var movimento := Vector2.ZERO

signal ataque_terminou

func ao_entrar() -> void:
	sprite = inimigo.get_node("Sprite")
	sprite.flip_h = abs(inimigo.position.direction_to(inimigo.jogador.position).angle()) > PI*.5
	sprite.play("carregando_ataque")
	sprite.connect("animation_finished", self, "_ao_animacao_carregar_terminar")
	progresso_pulo = distancia_pulo
	inimigo.direcao = Vector2.ZERO


func executar(delta: float) -> void:
	if progresso_pulo < distancia_pulo:
		movimento = (dir_pulo * velocidade_pulo) * delta
		movimento = inimigo.move_and_slide(movimento)
		progresso_pulo += movimento.length()
		if progresso_pulo >= distancia_pulo:
			emit_signal("ataque_terminou")


func ao_sair() -> void:
	if not sprite.is_connected("animation_finished", self, "_ao_animacao_carregar_terminar"):
		sprite.disconnect("animation_finished", self, "_ao_animacao_carregar_terminar")
	if not sprite.is_connected("frame_changed", self, "_ao_animacao_mudar_frame"):
		sprite.disconnect("frame_changed", self, "_ao_animacao_mudar_frame")


func _ao_animacao_carregar_terminar() -> void:
	var jogador = inimigo.jogador
	dir_pulo = inimigo.position.direction_to(inimigo.jogador.position)
	sprite.play("ataque_"+inimigo._pegar_suffixo_anim_dir(dir_pulo))
	sprite.connect("frame_changed", self, "_ao_animacao_mudar_frame")
	progresso_pulo = 0.0


func _ao_animacao_mudar_frame() -> void:
	if sprite.frame == indice_frame_pausa:
		sprite.stop()
