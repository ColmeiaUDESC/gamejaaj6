extends ProgressBar

export(Gradient) var gradiente: Gradient
export(Texture) var imagem_puro: Texture
export(Texture) var imagem_neutro: Texture
export(Texture) var imagem_impuro: Texture


func _ready() -> void:
	min_value = Globais.PUREZA_MINIMA
	max_value = Globais.PUREZA_MAXIMA

func definir_pureza(valor: float) -> void:
	var peso := Globais.porcentagem_puro(valor)

	match Globais.status_pureza(valor):
		Globais.STATUS_PUREZA_IMPURO:
			$TextureRect.texture = imagem_impuro
		Globais.STATUS_PUREZA_NEUTRO:
			$TextureRect.texture = imagem_neutro
		Globais.STATUS_PUREZA_PURO:
			$TextureRect.texture = imagem_puro

	value = valor
	get_stylebox("fg").bg_color = gradiente.interpolate(peso)
