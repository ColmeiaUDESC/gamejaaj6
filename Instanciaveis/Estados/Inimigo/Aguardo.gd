extends Estado

var direcao_alvo: Vector2 = Vector2.ZERO

func ao_entrar() -> void:
	_mudar_direcao_alvo()


func executar(delta: float) -> void:
	inimigo.direcao = direcao_alvo
	inimigo.gerenciar_movimento(delta)

func ao_sair() -> void:
	direcao_alvo = Vector2.ZERO
	$Timer.stop()


func _mudar_direcao_alvo():
	randomize()
	direcao_alvo = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
	$Timer.start()


func _on_Timer_timeout():
	_mudar_direcao_alvo()
