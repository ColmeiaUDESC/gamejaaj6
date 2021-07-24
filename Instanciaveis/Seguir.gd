extends Estado


func executar(_delta: float):
	inimigo.direcao = inimigo.position.direction_to(inimigo.jogador.position)
