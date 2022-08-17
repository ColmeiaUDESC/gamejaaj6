extends Node

const ATAQUES: Array = [
	"AtaqueRadial1",
	"AtaqueRadial2",
	"AtaqueRadial3",
	"AtaqueSpawn", # DEIXE ATAQUESPAWN POR ÚLTIMO!!!!!
]
const NODE_SISTEMA_SPAWN := "SistemaSpawnInimigo"

onready var inimigo = get_parent()

func _ready():
	call_deferred("escolher_ataque")


func escolher_ataque() -> void:
	randomize()
	var num_ataques := ATAQUES.size() - 1 if owner.get_node(NODE_SISTEMA_SPAWN).limite_foi_atingido() else ATAQUES.size()
	inimigo.mudar_de_estado(ATAQUES[randi() % num_ataques])


func _on_Visao_body_entered(body):
	if "Jogador" in body.name:
		inimigo.jogador = body

func _on_Visao_body_exited(body):
	if "Jogador" in body.name:
		inimigo.jogador = null
