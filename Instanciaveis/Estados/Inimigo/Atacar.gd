extends Estado

var esta_em_alcance = false
var valor_ataque = 1


func executar(_delta: float) -> void:
	inimigo.direcao = Vector2.ZERO
	inimigo.get_node("Ataque").atacar(inimigo.position.direction_to(inimigo.jogador.position))
	dano()


func dano():
	if esta_em_alcance:
		inimigo.jogador.inflige_dano(valor_ataque)


func _on_Ataque_body_entered(body):
	esta_em_alcance = true
func _on_Ataque_body_exited(body):
	esta_em_alcance = false
