extends "res://Instanciaveis/Projeteis/Projetil.gd"


func _on_Projetil_body_entered(body: PhysicsBody2D) -> void:
	if body.has_method("purificar"):
		emit_signal("acertou_inimigo", body)
		body.purificar(dano, atirador)
		if body.has_method("inflingir_empurrao"):
			body.inflingir_empurrao(global_position.direction_to(body.global_position) * forca_empurrao)
	queue_free()
