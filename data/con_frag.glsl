#version 330 core

layout(location = 0) out vec4 fcolor;

in vec2 v_texcoord;
//in vec4 v_color;

uniform sampler2D mainTex;

void main()
{
	float r = texture(mainTex, v_texcoord).r;
	fcolor = vec4(1.0,1.0,1.0,r);
}
