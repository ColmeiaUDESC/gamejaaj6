extends ProgressBar

export(Gradient) var gradiente: Gradient
export(float) var razao_impuro: float
export(float) var razao_puro: float
export(Texture) var imagem_puro: Texture
export(Texture) var imagem_neutro: Texture
export(Texture) var imagem_impuro: Texture


func definir_pureza(valor: float) -> void:
	var intervalo := abs(max_value - min_value)
	valor = clamp(valor, min_value, max_value)
	var peso = (valor - min_value) / intervalo

	if peso <= razao_impuro:
		$TextureRect.texture = imagem_impuro
	elif peso >= 1.0 - razao_puro:
		$TextureRect.texture = imagem_puro
	else:
		$TextureRect.texture = imagem_neutro

	value = valor
	get_stylebox("fg").bg_color = gradiente.interpolate(peso)
