extends Node

enum Personagens {
	Barata = 1,
	Monge = 2,
	Tigre = 3,
}

const CAMINHO_SAVE := "user://savegame%d.save"
const PUREZA_NEUTRA := 10
const QNT_SAVES := 3

var num_save_atual := 0
var personagem_atual: int = Personagens.Monge
var progresso_personagens := {}
var seed_atual := 0
var andar_atual := 0
var pureza_atual := 0

func _init() -> void:
	resetar()


func salvar() -> void:
	if num_save_atual < 0 and num_save_atual > QNT_SAVES:
		printerr("DadosSave: Nao foi possivel salvar devido ao num_save_atual possuir um valor invalido (%d)" % num_save_atual)
		return
	var arquivo_save := File.new()
	var _err := arquivo_save.open(CAMINHO_SAVE % num_save_atual, File.WRITE)
	arquivo_save.store_string(to_json(para_json()))
	arquivo_save.close()


func carregar() -> void:
	if num_save_atual < 0 and num_save_atual > QNT_SAVES:
		printerr("DadosSave: Nao foi possivel salvar devido ao num_save_atual possuir um valor invalido (%d)" % num_save_atual)
		return
	var arquivo_save := File.new()
	if not arquivo_save.file_exists(CAMINHO_SAVE % num_save_atual):
		resetar()
		salvar()
		return

	var _err := arquivo_save.open(CAMINHO_SAVE % num_save_atual, File.READ)
	de_json(parse_json(arquivo_save.get_as_text()))
	arquivo_save.close()


func resetar() -> void:
	personagem_atual = Personagens.Monge
	progresso_personagens = _gerar_progresso_personagens()
	seed_atual = 0
	andar_atual = 0
	pureza_atual = PUREZA_NEUTRA


func para_json() -> Dictionary:
	return {
		"personagem_atual": personagem_atual,
		"progresso_personagens": progresso_personagens,
		"seed_atual": seed_atual,
		"andar_atual": andar_atual,
		"pureza_atual": pureza_atual,
	}


func de_json(json: Dictionary) -> void:
	personagem_atual = json.get("personagem_atual", Personagens.Monge)
	# Isso tudo carrega o progresso de personagem. E complicado desse jeito para garantir seguranca dos dados e pra ser extendivel no futuro
	var prog_pers_default := _gerar_progresso_personagens()
	var prog_pers = json.get("progresso_personagens", prog_pers_default)
	for chave in progresso_personagens.keys():
		var prog: Array = prog_pers.get(str(chave), prog_pers_default[chave])
		progresso_personagens[chave] = prog_pers_default[chave]
		for i in range(progresso_personagens[chave].size()):
			progresso_personagens[chave][i] = prog[i] if i < prog.size() else false

	seed_atual = json.get("seed_atual", 0)
	andar_atual = json.get("andar_atual", 0)
	pureza_atual = json.get("pureza_atual", PUREZA_NEUTRA)


func _gerar_progresso_personagens() -> Dictionary:
	return {
		Personagens.Barata: [false, false, false],
		Personagens.Monge: [false, false, false],
		Personagens.Tigre: [false, false, false],
	}
