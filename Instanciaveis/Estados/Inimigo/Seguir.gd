extends Estado


func executar(_delta: float):
	inimigo.direcao = inimigo.global_position.direction_to(inimigo.jogador.global_position)
