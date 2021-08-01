extends Node2D

const PERSONAGENS = {
	DadosSave.Personagens.Monge: preload("res://Instanciaveis/Jogador.tscn"),
	DadosSave.Personagens.Barata: preload("res://Instanciaveis/JogadorBarata.tscn"),
	DadosSave.Personagens.Tigre: preload("res://Instanciaveis/JogadorTigre.tscn"),
}

export (Array, PackedScene) var andares := []

var andar
var sala_atual: Node2D
var jogador: KinematicBody2D
var mudando_de_sala := false

signal transicao_mudanca_de_sala_iniciada
signal transicao_mudanca_de_sala_finalizada

func _ready():
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


func finalizar_andar() -> void:
	DadosSave.andar_atual += 1
	var prox_cena := "res://Cenas/Jogo.tscn"
	DadosSave.pureza_atual = jogador.pureza
	if DadosSave.andar_atual == andares.size() + 1:
		_ganhar_jogo()
		jogador.get_node("UI/Fade").converter_para_fade_final()
		prox_cena = "res://Cenas/CutsceneFinal.tscn"

	jogador.get_node("UI/Fade").fade_in()
	yield(jogador.get_node("UI/Fade"), "fade_finalizado")
	var _err = get_tree().change_scene(prox_cena)


func _iniciar_jogo() -> void:
	if DadosSave.andar_atual == 0:
		DadosSave.andar_atual = 1
		DadosSave.seed_atual = rand_seed(OS.get_unix_time())[0]
		DadosSave.pureza_atual = DadosSave.PUREZA_NEUTRA

	andar = andares[DadosSave.andar_atual - 1].instance()
	add_child(andar)
	andar.gerar(DadosSave.seed_atual)

	jogador = PERSONAGENS[DadosSave.personagem_atual].instance()
	add_child(jogador)
	jogador.pureza = DadosSave.pureza_atual
	jogador.get_node("UI/Fade").fade_out()
	var _err := jogador.connect("morreu", self, "_ao_jogador_morrer")

	$Musica.stream = andar.musica
	$Musica.play()

	call_deferred("_ir_para_sala_inicial") # Necessario chamar ir para sala inicial no proximo quadro para nao ter problema com as animacoes das portas


# Chamado quando o jogador ganha o jogo
func _ganhar_jogo() -> void:
	var pers_atual := DadosSave.personagem_atual
	DadosSave.andar_atual = 0
	DadosSave.seed_atual = 0
#	DadosSave.pureza_atual = DadosSave.PUREZA_NEUTRA
	match Globais.status_pureza(DadosSave.pureza_atual):
		Globais.STATUS_PUREZA_IMPURO:
			DadosSave.progresso_personagens[pers_atual][0] = true
			DadosSave.personagem_atual = DadosSave.Personagens.Barata
		Globais.STATUS_PUREZA_NEUTRO:
			DadosSave.progresso_personagens[pers_atual][1] = true
			DadosSave.personagem_atual = DadosSave.Personagens.Monge
		Globais.STATUS_PUREZA_PURO:
			DadosSave.progresso_personagens[pers_atual][2] = true
			DadosSave.personagem_atual = DadosSave.Personagens.Tigre
	DadosSave.salvar()


func _notification(notif: int) -> void:
	if notif == MainLoop.NOTIFICATION_WM_QUIT_REQUEST and DadosSave.num_save_atual != 0:
		DadosSave.salvar()


func _ao_jogador_morrer() -> void:
	DadosSave.andar_atual = 0
	DadosSave.seed_atual = 0
	DadosSave.pureza_atual = DadosSave.PUREZA_NEUTRA
	DadosSave.salvar()


func _ir_para_sala_inicial() -> void:
	mudar_de_sala(andar.sala_inicial)
