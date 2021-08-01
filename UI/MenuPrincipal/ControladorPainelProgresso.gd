extends PanelContainer

export (String) var titulo = "Nome Personagem"

var puro_completo := false setget set_puro_completo, get_puro_completo
var neutro_completo := false setget set_neutro_completo, get_neutro_completo
var mal_completo := false setget set_mal_completo, get_mal_completo

func _ready() -> void:
	$VBoxContainer/Titulo.text = titulo


func set_puro_completo(value: bool) -> void:
	puro_completo = value
	$VBoxContainer/Progresso/Puro.material.set_shader_param("ativo", not value)


func get_puro_completo() -> bool:
	return puro_completo


func set_neutro_completo(value: bool) -> void:
	neutro_completo = value
	$VBoxContainer/Progresso/Neutro.material.set_shader_param("ativo", not value)


func get_neutro_completo() -> bool:
	return neutro_completo


func set_mal_completo(value: bool) -> void:
	mal_completo = value
	$VBoxContainer/Progresso/Mal.material.set_shader_param("ativo", not value)


func get_mal_completo() -> bool:
	return mal_completo
