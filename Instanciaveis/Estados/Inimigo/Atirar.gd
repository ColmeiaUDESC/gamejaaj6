extends Estado

export(PackedScene) var projetil: PackedScene
export(float) var dano: float = 1.0

func executar(_delta: float) -> void:
	if $Timer.is_stopped():
		$Timer.start()


func _on_Timer_timeout():
	if not inimigo.jogador or inimigo.esta_neutralizado():
		return
	var dir := inimigo.global_position.direction_to(inimigo.jogador.global_position)
	var projetil_instancia := projetil.instance()

	projetil_instancia.direcao = dir
	projetil_instancia.dano = dano
	projetil_instancia.position = inimigo.position

	inimigo.animar_ataque(dir)
	inimigo.get_node("SomAtacar").play()

	inimigo.get_parent().add_child(projetil_instancia)
