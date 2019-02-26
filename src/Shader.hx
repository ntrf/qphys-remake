


import sys.io.File;
import opengl.GL;

class Shader
{
	public var vertShader : Int;
	public var fragShader : Int;

	public var program : Int;

	public var vertSource : String;
	public var fragSource : String;

	public var projUni : Int;
	public var viewUni : Int;
	
	public function compileShader(type : Int, source : String)
	{
		var sh = GL.glCreateShader(type);

		GL.glShaderSource(sh, source);
		GL.glCompileShader(sh);

		var res = [0];

		GL.glGetShaderiv(sh, GL.GL_COMPILE_STATUS, res);

		trace('Shader compilation status => ${res[0]}');

		return sh;
	}

	public function compile()
	{
		vertShader = compileShader(GL.GL_VERTEX_SHADER, vertSource);
		fragShader = compileShader(GL.GL_FRAGMENT_SHADER, fragSource);

		var prog = GL.glCreateProgram();

		GL.glAttachShader(prog, vertShader);
		GL.glAttachShader(prog, fragShader);

		GL.glLinkProgram(prog);

		var res = [0];
		GL.glGetProgramiv(prog, GL.GL_LINK_STATUS, res);

		trace('Shader compilation status => ${res[0]}');

		projUni = GL.glGetUniformLocation(prog, "projection");
		viewUni = GL.glGetUniformLocation(prog, "view");

		program = prog;
	}

	public function loadShaders(file1 : String, file2 : String)
	{
		var content1 = File.getContent(file1);
		var content2 = File.getContent(file2);

		vertSource = content1;
		fragSource = content2;
	}

	public function setProjection(p : glm.Mat4, v : glm.Mat4)
	{
		var xv = [for (x in v.toFloatArray()) (cast x : cpp.Float32)];
		GL.glUniformMatrix4fv(viewUni, 1, false, xv);
		var xp = [for (x in p.toFloatArray()) (cast x : cpp.Float32)];
		GL.glUniformMatrix4fv(projUni, 1, false, xp);
	}

	public function new() {}
}