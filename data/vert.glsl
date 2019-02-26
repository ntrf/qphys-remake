#version 330 core

layout(location = 0) in vec3 i_position;
layout(location = 1) in vec2 i_texcoord;

out vec2 v_texcoord;

uniform mat4 projection;
uniform mat4 view;

void main()
{
	vec4 p = vec4(i_position, 1.0);

	p = projection * view * p;

	v_texcoord = i_texcoord;

	gl_Position = p;
}
