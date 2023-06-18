extends Node

export(int) var dano := 1
export(float) var forca_empurrao := 1.0

var jogador_colidindo: KinematicBody2D = null


func _ready() -> void:
	set_process(false)



func _process(_delta: float) -> void:
	if jogador_colidindo != null and is_instance_valid(jogador_colidindo):
		owner.infligir_dano_a_personagem(jogador_colidindo, dano, owner.global_position.direction_to(jogador_colidindo.global_position))
	

func _on_AreaDano_area_entered(area: Area2D) -> void:
	if "Jogador" in area.owner.name:
		jogador_colidindo = area.owner
		set_process(true)


func _on_AreaDano_area_exited(area: Area2D) -> void:
	if area.owner == jogador_colidindo:
		jogador_colidindo = null
		set_process(false)


func _on_AreaVisao_area_entered(area: Area2D) -> void:
	if "Jogador" in area.owner.name:
		owner.jogador = area.owner
		owner.mudar_de_estado("Seguir")


func _on_AreaVisao_area_exited(area: Area2D) -> void:
	if area.owner == owner.jogador:
		owner.jogador = null
		owner.mudar_de_estado("Aguardo")
