extends Area2D

onready var personagem = get_parent()
export var bit := 0

func desativar() -> void:
	set_deferred("monitorable", false)


func ativar() -> void:
	set_deferred("monitorable", true)
