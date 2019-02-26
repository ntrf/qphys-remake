#version 330 core

layout(location = 0) out vec4 fcolor;

in vec2 v_texcoord;

void main()
{
	vec2 uv = vec2(fract(v_texcoord.x), fract(v_texcoord.y));

	fcolor = vec4(uv, 0.5, 1.0);
}