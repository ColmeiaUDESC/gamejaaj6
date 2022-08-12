extends Node

export(Array, String) var ataques: Array
var inimigo = get_parent()


func _ready():
	escolher_ataque()


func escolher_ataque() -> void:
	randomize()
	var novo_estado: String = ataques[randi() % ataques.size()]
	inimigo.mudar_de_estado(novo_estado)
