extends AnimatedSprite


var max_purificao: float = 1.0
var purificacao: float = 0.0 setget set_purificacao


func set_purificacao(valor: float) -> void:
	purificacao = min(max_purificao, valor)
	material.set_shader_param("progresso_purificacao", purificacao / max_purificao)


func emitir_particulas_purificacao() -> void:
	$ParticulasPurificacao.emitting = true


func executar_anim_dano() -> void:
	$TweenDano.interpolate_property(material, "shader_param/coeficiente_mix_dano", 1.0, 0.0, .25, Tween.TRANS_QUART)
	$TweenDano.start()
