#version 330 core

layout(location = 0) in vec3 i_position;
layout(location = 1) in vec2 i_texcoord;
//layout(location = 2) in vec4 i_color;

out vec2 v_texcoord;
//out vec4 v_color;

uniform vec4 projection;

void main()
{
	vec2 p = projection.xy * i_position.xy + projection.zw;

	v_texcoord = i_texcoord;
//	v_color = i_color;

	gl_Position = vec4(p, i_position.z, 1.0);
}
