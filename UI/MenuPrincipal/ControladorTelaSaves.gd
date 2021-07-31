extends VBoxContainer


signal save_selecionado

func carregar_save(num_save: int) -> void:
	DadosSave.num_save_atual = num_save
	DadosSave.carregar()
	emit_signal("save_selecionado")


func _on_BotaoSave1_pressed():
	carregar_save(1)


func _on_BotaoSave2_pressed():
	carregar_save(2)


func _on_BotaoSave3_pressed():
	carregar_save(3)
