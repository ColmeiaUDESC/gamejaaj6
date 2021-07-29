extends Estado

var esta_em_alcance = false
var valor_ataque = 1


func executar(_delta: float) -> void:
	inimigo.direcao = Vector2.ZERO
	inimigo.get_node("Ataque/Sprite").visible = true
	inimigo.get_node("Ataque/Sprite").play("default")
	
	var posicao_relativa = (inimigo.position-inimigo.jogador.position).normalized()
	
	if abs(round(posicao_relativa.x)) > abs(round(posicao_relativa.y)):
		if round(posicao_relativa.x) > 0:
			inimigo.get_node("Ataque").set("rotation_degrees",0)
			dano()
				
		else:
			inimigo.get_node("Ataque").set("rotation_degrees",-180)
			dano()
	else:
		if round(posicao_relativa.y) > 0:
			inimigo.get_node("Ataque").set("rotation_degrees",-270)
			dano()
		else:
			inimigo.get_node("Ataque").set("rotation_degrees",-90)
			inimigo.get_node("Ataque/Sprite").visible = true
			inimigo.get_node("Ataque/Sprite").play("default")
			dano()
			

func ao_sair() -> void:
	inimigo.get_node("Ataque/Sprite").visible = false


func dano():
	if esta_em_alcance:
		inimigo.jogador.inflinge_dano(valor_ataque)
		
func _on_Ataque_body_entered(body):
	esta_em_alcance = true
func _on_Ataque_body_exited(body):
	esta_em_alcance = false
