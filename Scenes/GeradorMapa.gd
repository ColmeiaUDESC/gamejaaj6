extends Node2D

export (int) var media_salas := 6
export (int) var variancia_de_salas := 3
export (Vector2) var tamanho_das_salas := Vector2(10, 10)
export (Vector2) var tamanho_das_celulas := Vector2(128, 64)
export (PackedScene) var sala_inicial: PackedScene
export (Array, PackedScene) var salas_do_boss := []
export (Array, PackedScene) var salas := []

var _salas_criadas := []

const _DIRECOES := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]


func _ready():
	gerar()


func gerar() -> void:
	randomize()
	var pos_salas := [Vector2.ZERO]
	var salas_a_criar := media_salas + rand_range(-variancia_de_salas, variancia_de_salas+1) - 1

	# Gera as posicoes das salas
	while (salas_a_criar > 0):
		var sala_escolhida: Vector2 = pos_salas[rand_range(0, pos_salas.size())]
		var pos_nova_sala: Vector2 = sala_escolhida + _dir_aleatoria()

		if pos_salas.has(pos_nova_sala):
			continue

		pos_salas.append(pos_nova_sala)
		salas_a_criar-=1

	# Cria as salas
	var pos_mais_longe: Vector2 = pos_salas[0]
	for pos in pos_salas:
		var nova_sala: PackedScene = _sala_aleatoria() if pos != Vector2.ZERO else sala_inicial
		var sala_instancia = _criar_sala(nova_sala, pos)
		_salas_criadas.append(sala_instancia)

		if Vector2.ZERO.distance_squared_to(pos) > Vector2.ZERO.distance_squared_to(pos_mais_longe):
			pos_mais_longe = pos

		for dir in _DIRECOES:
			if pos_salas.has(pos + dir):
				sala_instancia.remover_porta(dir)

	# Cria a sala do boss
	var dir_sala_boss: Vector2 = Vector2.ZERO
	for dir in _DIRECOES:
		var pos_sala_boss: Vector2 =  pos_mais_longe + dir
		if !pos_salas.has(pos_sala_boss) and Vector2.ZERO.distance_squared_to(pos_sala_boss) > Vector2.ZERO.distance_squared_to(pos_mais_longe + dir_sala_boss):
			dir_sala_boss = dir
	var sala_boss = _criar_sala(_sala_boss_aleatoria(), pos_mais_longe + dir_sala_boss)
	sala_boss.remover_porta(-dir_sala_boss)
	_salas_criadas[pos_salas.find(pos_mais_longe)].remover_porta(dir_sala_boss)
	_salas_criadas.append(sala_boss)



func _converter_para_isometrico(pos: Vector2) -> Vector2:
	return Vector2(pos.x - pos.y, pos.x + pos.y)


func _dir_aleatoria() -> Vector2:
	return _DIRECOES[randi() % _DIRECOES.size()]


func _sala_aleatoria() -> PackedScene:
	return salas[randi() % salas.size()]


func _sala_boss_aleatoria() -> PackedScene:
	return salas_do_boss[randi() % salas_do_boss.size()]


func _criar_sala(sala: PackedScene, pos: Vector2):
	var nova_sala = sala.instance()
	nova_sala.position = _converter_para_isometrico(pos) * tamanho_das_salas * tamanho_das_celulas / Vector2(2,2)
	add_child(nova_sala)
	return nova_sala
