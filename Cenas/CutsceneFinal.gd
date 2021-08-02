extends Panel

const MUSICA_PURO = preload("res://Conteudos/Musicas/Ost/FinalPuro.mp3")
const MUSICA_NEUTRO = preload("res://Conteudos/Musicas/Ost/FinalNeutro.mp3")
const MUSICA_IMPURO = preload("res://Conteudos/Musicas/Ost/FinalImpuro.mp3")
const VELOCIDADE_APARICAO_TEXTO := 0.5
const TEXTO_PURO := """Você foi bom e misericordioso, meu seguidor
Reencarne, em um ser tão puro quanto vós"""
const TEXTO_NEUTRO := """Teu coração é bom, mas ainda possui uma energia maligna
Reencarne em um ser mundano"""
const TEXTO_IMPURO := """Tu foste o pior dos demonios
Sua punição será ser uma criatura patética"""

export (float) var velocidade_texto := 1.0

var _texto_atual: String
var _num_linha_atual: int


func _ready():
	match Globais.status_pureza(DadosSave.pureza_atual):
		Globais.STATUS_PUREZA_IMPURO:
			$AudioStreamPlayer.stream = MUSICA_IMPURO
			_set_texto(TEXTO_IMPURO)
		Globais.STATUS_PUREZA_NEUTRO:
			$AudioStreamPlayer.stream = MUSICA_NEUTRO
			_set_texto(TEXTO_NEUTRO)
		Globais.STATUS_PUREZA_PURO:
			$AudioStreamPlayer.stream = MUSICA_PURO
			_set_texto(TEXTO_PURO)

	$AudioStreamPlayer.play()


func _process(delta: float):
	if $VBoxContainer/CentralizarTexto/Label.percent_visible != 1:
		$VBoxContainer/CentralizarTexto/Label.percent_visible += delta * velocidade_texto
		if $VBoxContainer/CentralizarTexto/Label.percent_visible >= 1:
			$VBoxContainer/EnterContinuar/AnimationPlayer.play("aparecer")
	elif _num_linha_atual < _qnt_linhas(_texto_atual) - 1 and Input.is_key_pressed(KEY_ENTER):
		_prox_linha()
	elif _num_linha_atual == _qnt_linhas(_texto_atual) - 1:
		_num_linha_atual+=1
		_esconder_enter_continuar()
		_mostrar_botoes()


func _set_texto(valor: String) -> void:
	_texto_atual = valor
	_num_linha_atual = -1
	_prox_linha()


func _prox_linha() -> void:
	_num_linha_atual += 1
	$VBoxContainer/CentralizarTexto/Label.text = _pegar_linha(_texto_atual, _num_linha_atual)
	$VBoxContainer/CentralizarTexto/Label.percent_visible = 0
	_esconder_enter_continuar()


func _pegar_linha(texto: String, linha: int) -> String:
	return texto.split("\n")[linha]


func _qnt_linhas(texto: String) -> int:
	return texto.split("\n").size()


func _esconder_enter_continuar() -> void:
	$VBoxContainer/EnterContinuar.self_modulate = Color.transparent
	$VBoxContainer/EnterContinuar/AnimationPlayer.stop()


func _mostrar_enter_continuar() -> void:
	pass


func _mostrar_botoes() -> void:
	$VBoxContainer/Botoes/MargemBotaoReencarnar/BotaoReencarnar.show()
	$VBoxContainer/Botoes/MargemBotaoReencarnar/BotaoReencarnar.disabled = false
	$VBoxContainer/Botoes/MargemBotaoVoltar/BotaoVoltar.show()
	$VBoxContainer/Botoes/MargemBotaoVoltar/BotaoVoltar.disabled = false


func _on_BotaoReencarnar_pressed():
	var _err = get_tree().change_scene("res://Cenas/Jogo.tscn")


func _on_BotaoVoltar_pressed():
	var _err = get_tree().change_scene("res://Cenas/MenuPrincipal.tscn")
