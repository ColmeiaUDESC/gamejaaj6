extends Node2D

export(NodePath) var porta_norte: NodePath
export(NodePath) var porta_sul: NodePath
export(NodePath) var porta_esquerda: NodePath
export(NodePath) var porta_direita: NodePath

func remover_porta(dir_porta: Vector2) -> void:
	var caminho_porta: NodePath
	match(dir_porta):
		Vector2.UP:
			caminho_porta = porta_norte
		Vector2.DOWN:
			caminho_porta = porta_sul
		Vector2.LEFT:
			caminho_porta = porta_esquerda
		Vector2.RIGHT:
			caminho_porta = porta_direita
	if caminho_porta.is_empty():
		printerr("ERRO: dir_porta de valor "+var2str(dir_porta)+" e invalido!")

	get_node(caminho_porta).queue_free()
