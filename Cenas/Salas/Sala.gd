extends Node2D

const TAMANHO_SALA := Vector2(11,11)
const DESLOCAMENTO_JOGADOR_AO_ENTRAR := 128

var posicao_na_matriz = Vector2.ZERO
var dir_salas_vizinhas: Array = []
var portas := []
var spawn_inimigos := []
var _cont_inimigos_ativos := 0
var _completo := false

signal entrou
signal saiu
signal completo

func _ready() -> void:
	if $Componentes/Portas.get_child_count() != 4:
		printerr("Erro: Ha um numero incorreto de portas presentes na sala. A sala deve possuir 4 portas")

	for porta in $Componentes/Portas.get_children():
		if not dir_salas_vizinhas.has(porta.direcao):
			porta.converter_para_parede()
		else:
			portas.append(porta)
			var _erro = porta.connect("body_entered", self, "_ao_corpo_encostar_porta", [porta.direcao])

	for spawn_inimigo in $Componentes/Inimigos.get_children():
		spawn_inimigos.append(spawn_inimigo)

	if spawn_inimigos.size() == 0:
		_completo = true

	call_deferred("_esconder")
	call_deferred("_abrir_portas")
#	print(get_path(), ":ready pronto")


func ao_entrar() -> void:
	_mostrar()
	if not _completo:
		_fechar_portas()
		_spawnar_inimigos()

	emit_signal("entrou")
#	print(get_path(), ":entro")


func ao_sair() -> void:
	_esconder()
	_abrir_portas()
	_resetar_inimigos()
	emit_signal("saiu")
#	print(get_path(), ":saiu")


func ao_completar() -> void:
	_abrir_portas()
	emit_signal("completo")
#	print(get_path(), ":completo")


func mudar_sala(dir: Vector2) -> void:
	get_node("/root/Jogo").mudar_de_sala(get_parent().pegar_sala_em_pos(posicao_na_matriz + dir), -dir)


func inserir_jogador(jogador: KinematicBody2D, direcao_porta: Vector2) -> void:
	if jogador.get_parent():
		jogador.get_parent().remove_child(jogador)

	var pos_porta := pegar_pos_porta_na_direcao(direcao_porta)
	var dir_porta_centro := pos_porta.direction_to(Vector2.ZERO)
	jogador.position = pos_porta + dir_porta_centro * DESLOCAMENTO_JOGADOR_AO_ENTRAR

	$Componentes/Jogador.call_deferred("add_child", jogador)


func pegar_salas_vizinhas() -> Array:
	var salas_vizinhas = []
	for dir in dir_salas_vizinhas:
		salas_vizinhas.append(get_parent().pegar_sala_em_pos(posicao_na_matriz + dir))
	return salas_vizinhas


func pegar_pos_porta_na_direcao(dir: Vector2) -> Vector2:
	for porta in portas:
		if porta.direcao == dir:
			return porta.position

	return position


func _abrir_portas() -> void:
	for porta in portas:
		porta.abrir()


func _fechar_portas() -> void:
	for porta in portas:
		porta.fechar()


func _mostrar() -> void:
	$Animacoes.play("aparecendo")


func _esconder() -> void:
	$Animacoes.play("sumindo")


func _spawnar_inimigos() -> void:
	for spawn_inimigo in spawn_inimigos:
		spawn_inimigo.spawnar()
		_cont_inimigos_ativos+=1


func _resetar_inimigos() -> void:
	for spawn_inimigo in spawn_inimigos:
		spawn_inimigo.resetar()

	_cont_inimigos_ativos = 0


func _ao_corpo_encostar_porta(corpo: Node2D, dir_porta: Vector2) -> void:
	if corpo.is_in_group("jogador"):
		mudar_sala(dir_porta)


func _ao_inimigo_neutralizado() -> void:
	_cont_inimigos_ativos -= 1
	if _cont_inimigos_ativos <= 0:
		ao_completar()
