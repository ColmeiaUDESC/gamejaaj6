extends Node

enum Personagens {
	Barata = 1,
	Monge = 2,
	Tigre = 3,
}

const CAMINHO_SAVE := "user://savegame%d.save"

var num_save_atual := 0
var dados := {}

func _init() -> void:
	resetar()


func salvar(num_save: int) -> void:
	var arquivo_save := File.new()
	var _err := arquivo_save.open(CAMINHO_SAVE % num_save, File.WRITE)
	arquivo_save.store_string(to_json(dados))
	arquivo_save.close()


func carregar(num_save: int) -> void:
	var arquivo_save := File.new()
	if not arquivo_save.file_exists(CAMINHO_SAVE % num_save):
		resetar()
		num_save_atual = num_save
		salvar(num_save)
		return

	var _err := arquivo_save.open(CAMINHO_SAVE % num_save, File.READ)
	dados = parse_json(arquivo_save.get_as_text())
	arquivo_save.close()
	num_save_atual = num_save


func resetar() -> void:
	num_save_atual = 0
	dados = {
		"personagem_atual":  Personagens.Monge,
		"progresso_personagens": {
			Personagens.Barata: [false, false, false],
			Personagens.Monge: [false, false, false],
			Personagens.Tigre: [false, false, false],
		},
		"seed_atual": 0,
		"andar_atual": 0,
	}
