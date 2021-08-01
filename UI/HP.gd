extends ProgressBar

onready var jogador = get_parent().get_parent()


func _process(_delta):
	value = jogador.vida_atual
	$Label.text = "%d/%d" % ([value, jogador.vida_max])
