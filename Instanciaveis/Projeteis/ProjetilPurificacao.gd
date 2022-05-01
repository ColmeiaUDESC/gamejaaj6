extends "res://Instanciaveis/Projeteis/Projetil.gd"


func _ao_colidir(colisor: CollisionObject2D) -> void:
	if "personagem" in colisor:
		var personagem = colisor.personagem
		emit_signal("acertou_inimigo", personagem)
		personagem.purificar(dano, atirador)
		personagem.inflingir_empurrao(global_position.direction_to(personagem.global_position) * forca_empurrao)
	queue_free()
