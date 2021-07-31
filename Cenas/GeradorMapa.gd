extends Node2D

export (int) var media_salas := 6
export (int) var variancia_de_salas := 3
export (Vector2) var tamanho_das_salas := Vector2(10, 10)
export (Vector2) var tamanho_das_celulas := Vector2(128, 64)
export (PackedScene) var cena_sala_inicial: PackedScene
export (Array, PackedScene) var cena_salas_do_boss := []
export (Array, PackedScene) var cenas_salas := []

var sala_inicial: Node2D
var sala_do_boss: Node2D
var _salas_criadas := []

const _DIRECOES := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]



func gerar(seed_rng: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_rng
	var pos_salas := [Vector2.ZERO]
	var salas_a_criar := media_salas + rng.randi_range(-variancia_de_salas, variancia_de_salas+1) - 1

	# Gera as posicoes das cenas_salas
	var pos_mais_longe: Vector2 = pos_salas[0]
	while (salas_a_criar > 0):
		var sala_escolhida: Vector2 = pos_salas[rng.randi_range(0, pos_salas.size())]
		var pos_nova_sala: Vector2 = sala_escolhida + _dir_aleatoria(rng)

		if pos_salas.has(pos_nova_sala):
			continue

		if Vector2.ZERO.distance_squared_to(pos_nova_sala) > Vector2.ZERO.distance_squared_to(pos_mais_longe):
			pos_mais_longe = pos_nova_sala

		pos_salas.append(pos_nova_sala)
		salas_a_criar-=1


	# Adiciona a posicao da sala do boss na lista de posicoes
	var pos_sala_boss: Vector2 = Vector2.ZERO
	for dir in _DIRECOES:
		var pos: Vector2 =  pos_mais_longe + dir
		if !pos_salas.has(pos) and Vector2.ZERO.distance_squared_to(pos) > Vector2.ZERO.distance_squared_to(pos_sala_boss):
			pos_sala_boss = pos
	pos_salas.append(pos_sala_boss)

	# Cria as cenas_salas
	for pos in pos_salas:
		var sala_instancia: Node2D

		if pos == Vector2.ZERO:
			sala_instancia = _criar_sala(cena_sala_inicial, pos, pos_salas)
			sala_inicial = sala_instancia
		elif pos == pos_sala_boss:
			sala_instancia = _criar_sala(_sala_boss_aleatoria(rng), pos, pos_salas)
			sala_do_boss = sala_instancia
		else:
			sala_instancia = _criar_sala(_sala_aleatoria(rng), pos, pos_salas)

		_salas_criadas.append(sala_instancia)


func pegar_sala_em_pos(pos: Vector2):
	for sala in get_children():
		if sala.posicao_na_matriz == pos:
			return sala

	return null


func _converter_para_isometrico(pos: Vector2) -> Vector2:
	return Vector2(pos.x - pos.y, pos.x + pos.y)


func _dir_aleatoria(rng: RandomNumberGenerator) -> Vector2:
	return _DIRECOES[rng.randi() % _DIRECOES.size()]


func _sala_aleatoria(rng: RandomNumberGenerator) -> PackedScene:
	return cenas_salas[rng.randi() % cenas_salas.size()]


func _sala_boss_aleatoria(rng: RandomNumberGenerator) -> PackedScene:
	return cena_salas_do_boss[rng.randi() % cena_salas_do_boss.size()]


func _criar_sala(sala: PackedScene, pos: Vector2, pos_salas: Array):
	var dir_salas_vizinhas := []

	for direcao in _DIRECOES:
		if pos_salas.has(pos+direcao):
			dir_salas_vizinhas.append(direcao)

	var nova_sala = sala.instance()
	nova_sala.position = _converter_para_isometrico(pos) * tamanho_das_salas * tamanho_das_celulas / Vector2(2,2)
	nova_sala.posicao_na_matriz = pos
	nova_sala.dir_salas_vizinhas = dir_salas_vizinhas
	add_child(nova_sala)
	return nova_sala
