extends Node2D

var sala_atual: Node2D
var jogador: KinematicBody2D
var mudando_de_sala := false

signal transicao_mudanca_de_sala_iniciada
signal transicao_mudanca_de_sala_finalizada

func _ready():
	jogador = $Jogador
	_iniciar_jogo()


func mudar_de_sala(nova_sala: Node2D, direcao_porta: Vector2 = Vector2.ZERO) -> void:
	if not $DelayMudarSala.is_stopped() or mudando_de_sala:
		return
	mudando_de_sala = true

	nova_sala.mostrar()

	if sala_atual:
		var velocidade_anterior: int = jogador.velocidade
		var pos_final_cam: Vector2 = nova_sala.pegar_porta_na_direcao(direcao_porta).pegar_pos_teleporte_jogador(true)
		jogador.velocidade = 0
		sala_atual.ao_sair()
		jogador.transicionar_camera(pos_final_cam)
		jogador.player_animacao.play("sumir")
		emit_signal("transicao_mudanca_de_sala_iniciada")
		yield(jogador.tween_transicao, "tween_completed")
		emit_signal("transicao_mudanca_de_sala_finalizada")
		jogador.velocidade = velocidade_anterior
		jogador.player_animacao.play("aparecer")
		sala_atual.esconder()

	nova_sala.inserir_jogador(jogador, direcao_porta)
	nova_sala.ao_entrar()
	sala_atual = nova_sala
	mudando_de_sala = false
	$DelayMudarSala.start()


func _iniciar_jogo() -> void:
	if DadosSave.andar_atual == 0:
		DadosSave.andar_atual = 1
		DadosSave.seed_atual = rand_seed(OS.get_unix_time())[0]
		DadosSave.pureza_atual = DadosSave.PUREZA_NEUTRA

	$Jogador.pureza = DadosSave.pureza_atual
	$GeradorDeMapas.gerar(DadosSave.seed_atual)
	call_deferred("_ir_para_sala_inicial") # Necessario chamar ir para sala inicial no proximo quadro para nao ter problema com as animacoes das portas


func _ao_jogador_morrer() -> void:
	DadosSave.andar_atual = 0


func _ir_para_sala_inicial() -> void:
	mudar_de_sala($GeradorDeMapas.sala_inicial)
