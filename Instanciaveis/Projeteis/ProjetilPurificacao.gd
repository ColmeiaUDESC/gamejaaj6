extends "res://Instanciaveis/Projeteis/Projetil.gd"


func _on_Projetil_body_entered(body: PhysicsBody2D) -> void:
	if body.has_method("purificar"):
		body.purificar(dano)
	queue_free()
