extends Estado

var _anim_player: AnimationPlayer = null

signal finalizado

func _ready() -> void:
	for node in get_children():
		_anim_player = node if node is AnimationPlayer else null
	if _anim_player == null:
		printerr(get_path(), ": Node filho do tipo AnimationPlayer ausente")
	
	var _err := _anim_player.connect("animation_finished", self, "_ao_animacao_finalizar")


func ao_entrar() -> void:
	if _anim_player == null: return
	_anim_player.play("default")


func ao_sair() -> void:
	if _anim_player == null: return
	_anim_player.stop()


func _ao_animacao_finalizar(_nome: String) -> void:
	_anim_player.stop()
	emit_signal("finalizado")
