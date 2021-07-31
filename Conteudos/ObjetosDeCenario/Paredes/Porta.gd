extends Area2D

const DESLOCAMENTO_JOGADOR_AO_ENTRAR := 128

export(Vector2) var direcao: Vector2
onready var animador_porta: AnimationPlayer = $Porta/AnimationPlayer

const _ASSOC_NOME_DIRECAO = {
	"esquerda": Vector2.LEFT,
	"direita": Vector2.RIGHT,
	"norte": Vector2.UP,
	"sul": Vector2.DOWN
}

func _ready():
	_definir_direcao_padrao()


func converter_para_parede() -> void:
#	print(get_path(),":convertendo para parede")
	$CollisionShape2D.set_deferred("disabled", true)
	_animar_porta_fechando()


func abrir() -> void:
#	print(get_path(),":abrindo")
	$CollisionShape2D.set_deferred("disabled", false)
	_animar_porta_abrindo()


func fechar() -> void:
	print(get_path(),":fechando")
	$CollisionShape2D.set_deferred("disabled", true)
	_animar_porta_fechando()


func _animar_porta_abrindo() -> void:
	animador_porta.play("abrir")


func _animar_porta_fechando() -> void:
	animador_porta.play("fechar")


func pegar_pos_teleporte_jogador(e_global: bool = false) -> Vector2:
	var pos_porta: Vector2 = global_position if e_global else position
	var dir_porta_centro: Vector2 = position.direction_to(Vector2.ZERO)
	return pos_porta + dir_porta_centro * DESLOCAMENTO_JOGADOR_AO_ENTRAR


func _definir_direcao_padrao() -> void:
	if not direcao == Vector2.ZERO:
		return

	for identificador in _ASSOC_NOME_DIRECAO.keys():
		if identificador in name.to_lower():
			direcao = _ASSOC_NOME_DIRECAO[identificador]
			return

	printerr("Erro! direcao esta indefinido! Defina uma direcao da porta!")
