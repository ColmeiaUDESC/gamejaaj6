extends Estado


func executar(_delta: float) -> void:
	inimigo.direcao = Vector2.ZERO
	inimigo.get_node("Ataque/Sprite").visible = true
	inimigo.get_node("Ataque/Sprite").play("default")
	
	var posicao_relativa = (inimigo.position-inimigo.jogador.position).normalized()
	
	if abs(round(posicao_relativa.x)) > abs(round(posicao_relativa.y)):
		if round(posicao_relativa.x) > 0:
			inimigo.get_node("Ataque").set("rotation_degrees",0)
		else:
			inimigo.get_node("Ataque").set("rotation_degrees",-180)
	else:
		if round(posicao_relativa.y) > 0:
			inimigo.get_node("Ataque").set("rotation_degrees",-270)
		else:
				inimigo.get_node("Ataque").set("rotation_degrees",-90)
				inimigo.get_node("Ataque/Sprite").visible = true
				inimigo.get_node("Ataque/Sprite").play("default")
				

func ao_sair() -> void:
	inimigo.get_node("Ataque/Sprite").visible = false
	
