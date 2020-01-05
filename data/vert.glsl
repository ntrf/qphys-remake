#version 330 core

layout(location = 0) in vec3 i_position;
layout(location = 1) in vec2 i_texcoord;

out vec2 v_texcoord;

layout(std140) uniform CameraBlock
{
	mat4 viewMatrix;
	mat4 projMatrix;
} camera;

void main()
{
	vec4 p = vec4(i_position, 1.0);

	p = camera.projMatrix * (camera.viewMatrix * p);

	v_texcoord = i_texcoord;

	gl_Position = p;
}
