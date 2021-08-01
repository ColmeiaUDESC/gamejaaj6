extends Estado

var esta_em_alcance = false
var valor_ataque = 1


func executar(_delta: float) -> void:
	inimigo.direcao = Vector2.ZERO
	inimigo.get_node("Ataque").atacar(inimigo.global_position.direction_to(inimigo.jogador.global_position))
	dano()


func dano():
	if esta_em_alcance:
		if not inimigo.jogador.is_connected("recebido_dano", inimigo, "_ao_infligir_dano"):
			inimigo.jogador.connect("recebido_dano", inimigo, "_ao_infligir_dano", [], CONNECT_ONESHOT)
		inimigo.jogador.inflige_dano(valor_ataque)


func _on_Ataque_body_entered(_body):
	esta_em_alcance = true
func _on_Ataque_body_exited(_body):
	esta_em_alcance = false
