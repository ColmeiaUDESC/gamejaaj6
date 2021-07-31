shader_type canvas_item;
uniform bool ativo;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (ativo){
	    float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	    COLOR.rgb = vec3(avg);
	}
}