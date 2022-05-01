extends Estado

export(PackedScene) var projetil: PackedScene
export(float) var dano: float = 1.0

var _atacando: bool = false

func ao_entrar():
	inimigo.sprite.connect("animation_finished", self, "_ao_animacao_acabar")

func executar(delta: float) -> void:
	if $Timer.is_stopped():
		$Timer.start()
	if _atacando:
		return
	var dir := -Vector2.LEFT
	if inimigo.jogador:
		dir = inimigo.global_position.direction_to(inimigo.jogador.global_position)
	inimigo.direcao = dir
	inimigo.gerenciar_movimento(delta)

func ao_sair():
	if inimigo.sprite.is_connected("animation_finished", self, "_ao_animacao_acabar"):
		inimigo.sprite.disconnect("animation_finished", self, "_ao_animacao_acabar")

func _on_Timer_timeout():
	if not inimigo.jogador or inimigo.esta_neutralizado():
		return
	var dir := inimigo.global_position.direction_to(inimigo.jogador.global_position)
	var projetil_instancia := projetil.instance()

	projetil_instancia.direcao = dir
	projetil_instancia.dano = dano
	projetil_instancia.position = inimigo.position

	_atacando = true
	inimigo.sprite.play("atacando")
	inimigo.get_node("SomAtacar").play()

	inimigo.get_parent().add_child(projetil_instancia)


func _ao_animacao_acabar() -> void:
	_atacando = false
