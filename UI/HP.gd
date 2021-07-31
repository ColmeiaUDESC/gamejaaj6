extends Control

onready var jogador = get_parent().get_parent()

onready var aux_max = 0
onready var aux_atual = 0

func _process(_delta):
	#So pra nao ficar mexendo no node sem necessidade
	if aux_max != jogador.vida_max or aux_atual != jogador.vida_atual:
		$Valores/Maximo.text = "/%d" % int(jogador.vida_max)
		$Valores/Atual.text = str(int(jogador.vida_atual))

		# Diminui ou "esvazia" a barra relativa ao tamanho, o float e necessario pois divisao de
		# inteiros menor que 1 retorna zero
		$Barra1.set("margin_right",104*(float(jogador.vida_atual)/float(jogador.vida_max)))

		aux_max = jogador.vida_max
		aux_atual = jogador.vida_atual
