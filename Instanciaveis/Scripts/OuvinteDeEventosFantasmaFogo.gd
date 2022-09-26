extends Node

var _vel_original: float

func _ready() -> void:
	_vel_original = 


func _on_Visao_body_entered(body):
	if body.name == "Jogador":
		owner.jogador = body
		owner.mudar_de_estado("Seguir")
		$Timer.start()


func _on_Visao_body_exited(body):
	if body.name == "Jogador":
		owner.jogador = null
		owner.mudar_de_estado("Aguardo")
		$Timer.stop()


func _on_Timer_timeout():
	owner.mudar_de_estado("Atacar")


func _on_Atacar_finalizado():
	pass # Replace with function body.
