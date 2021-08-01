extends HBoxContainer

const TEXTO_CONTINUAR := "Continuar"
const TEXTO_NOVO_JOGO := "Novo Jogo"


func inicializar() -> void:
	$MarginContainer/Botoes/BotaoJogar.text = TEXTO_NOVO_JOGO if DadosSave.andar_atual == 0 else TEXTO_CONTINUAR
	var progresso_personagens: Dictionary = DadosSave.progresso_personagens
	for personagem_chave in progresso_personagens.keys():
		var puro_completo: bool = progresso_personagens[personagem_chave][0]
		var neutro_completo: bool = progresso_personagens[personagem_chave][1]
		var mal_completo: bool = progresso_personagens[personagem_chave][2]
		var painel: Control
		match (int(personagem_chave)):
			DadosSave.Personagens.Barata:
				painel = $Progesso/VBoxContainer/PainelProgressoBarata
			DadosSave.Personagens.Monge:
				painel = $Progesso/VBoxContainer/PainelProgressoMonge
			DadosSave.Personagens.Tigre:
				painel = $Progesso/VBoxContainer/PainelProgressoTigre
		painel.puro_completo = puro_completo
		painel.neutro_completo = neutro_completo
		painel.mal_completo = mal_completo


func _on_BotaoJogar_pressed():
	get_parent().get_node("Fade").show()
	get_parent().get_node("Fade").fade_in()
	yield(get_parent().get_node("Fade"), "fade_finalizado")
	var _err := get_tree().change_scene("res://Cenas/Jogo.tscn")
