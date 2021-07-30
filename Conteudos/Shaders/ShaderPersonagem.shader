shader_type canvas_item;
uniform float brilho_purificacao = 1.0;
uniform float progresso_purificacao : hint_range(0.0, 1.0) = 0.0;
uniform float coeficiente_mix_dano : hint_range(0.0, 1.0) = 0.0;
uniform vec4 cor_purificacao : hint_color = vec4(1);
uniform vec4 cor_dano : hint_color = vec4(1, 0, 0, 1);

void fragment(){
	COLOR = texture(TEXTURE, UV);
	if (UV.y >= 1.0 - progresso_purificacao){
		float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
		COLOR.rgb = cor_purificacao.rgb * avg * brilho_purificacao;
	}
	COLOR.rgb = mix(COLOR.rgb, cor_dano.rgb, coeficiente_mix_dano);
}