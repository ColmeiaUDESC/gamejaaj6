extends Estado


func executar(delta: float):
	inimigo.direcao = inimigo.global_position.direction_to(inimigo.jogador.global_position)
	inimigo.gerenciar_movimento(delta)
