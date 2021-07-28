extends Node2D

var sala_atual: Node2D
var jogador: KinematicBody2D

func _ready():
	jogador = $Jogador
	_iniciar_jogo()


func mudar_de_sala(nova_sala: Node2D, direcao_porta: Vector2 = Vector2.ZERO):
	if sala_atual:
		sala_atual.ao_sair()

	nova_sala.inserir_jogador(jogador, direcao_porta)
	nova_sala.ao_entrar()
	sala_atual = nova_sala


func _iniciar_jogo() -> void:
	$GeradorDeMapas.gerar()
	call_deferred("_ir_para_sala_inicial") # Necessario chamar ir para sala inicial no proximo quadro para nao ter problema com as animacoes das portas


func _ir_para_sala_inicial() -> void:
	mudar_de_sala($GeradorDeMapas.sala_inicial)
