extends Node

export(int) var max_inimigos: int = 10

onready var inimigo = owner

var num_inimigos := 0

signal spawnado

func spawnar(info_inimigo: PackedScene, particulas: PackedScene, deslocamento: Vector2) -> void:
	if num_inimigos >= max_inimigos:
		return
	
	var novo_spawn: Node2D = info_inimigo.instance()
	var pos_inimigo: Vector2 = inimigo.position + deslocamento
	
	if particulas != null:
		var particulas_instancia: Particles2D = particulas.instance()
		particulas_instancia.position = pos_inimigo
		var _err := particulas_instancia.connect("ready", particulas_instancia, "set_emitting", [true])
		inimigo.get_parent().call_deferred("add_child", particulas_instancia)
	
	novo_spawn.position = pos_inimigo
	novo_spawn.connect("neutralizado", self, "_ao_inimigo_spawnado_ser_neutralizado")
	inimigo.get_parent().get_parent().get_parent().add_inimigo(novo_spawn) # RUIM: Tentar pegar a sala de uma forma melhor
	
	num_inimigos = clamp(num_inimigos + 1, 0, max_inimigos)
	
	emit_signal("spawnado")


func spawnar_raio_aleatorio(info_inimigo: PackedScene, particulas: PackedScene, raio_min_max: Vector2) -> void:
	raio_min_max.x = max(raio_min_max.x, 0.0)
	if raio_min_max.y < raio_min_max.x:
		var tmp := raio_min_max.y
		raio_min_max.y = raio_min_max.x
		raio_min_max.x = tmp
	var raio := raio_min_max.x + randf() * (raio_min_max.y - raio_min_max.x)
	spawnar(info_inimigo, particulas, Vector2(randf(), randf()).normalized() * raio)


func limite_foi_atingido() -> bool:
	return num_inimigos >= max_inimigos


func _ao_inimigo_spawnado_ser_neutralizado(_foi_morto: bool) -> void:
	num_inimigos = clamp(num_inimigos - 1, 0, max_inimigos)
