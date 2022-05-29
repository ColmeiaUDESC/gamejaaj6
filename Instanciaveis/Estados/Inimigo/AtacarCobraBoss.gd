extends Estado

export(float) var velocidade_angular_tiro_radial = 0.5
export(int) var qnt_tiro_radial := 5
export(PackedScene) var projetil: PackedScene
export(float) var dano: float = 1.0

var angulo_atual: float = 0.0

func executar(delta: float) -> void:
	angulo_atual += delta * velocidade_angular_tiro_radial
	if $DelayTiroRadial.is_stopped():
		$DelayTiroRadial.start()
	if $DelayTiroNormal.is_stopped():
		$DelayTiroNormal.start()


func instanciar_tiro(dir: Vector2) -> void:
	var projetil_instancia := projetil.instance()

	projetil_instancia.direcao = dir
	projetil_instancia.dano = dano
	projetil_instancia.position = inimigo.position

	inimigo.get_parent().add_child(projetil_instancia)


func _on_DelayTiroRadial_timeout():
	if inimigo.esta_neutralizado():
		return

	for i in range(qnt_tiro_radial):
		instanciar_tiro(Vector2.RIGHT.rotated(angulo_atual + i * (2 * PI) / qnt_tiro_radial))


func _on_DelayTiroNormal_timeout():
	if inimigo.esta_neutralizado():
		return
	var dir := inimigo.global_position.direction_to(inimigo.jogador.global_position)
	instanciar_tiro(dir)
	inimigo.sprite.play("atacando")
	inimigo.get_node("SomAtacar").play()
