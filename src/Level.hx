

import opengl.GL;
import sys.io.File;

class Level
{
	public var vertexData : haxe.io.Bytes;
	public var indexData : haxe.io.Bytes;

	public function new()
	{

	}

	public function load()
	{
		var levelData = File.read("../data/vx.bin");

		vertexData = levelData.read(1128992);
		indexData = levelData.read(245940);
	}

	public var vertexVbo : Int;
	public var indexVbo : Int;

	public function makeGl()
	{
		var glvbos = [0, 0];
		GL.glGenBuffers(2, glvbos);

		vertexVbo = glvbos[0];
		indexVbo = glvbos[1];

		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vertexVbo);
		GL.glBufferData(GL.GL_ARRAY_BUFFER, vertexData.length, vertexData.getData(), GL.GL_DYNAMIC_DRAW);

		GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, indexVbo);
		GL.glBufferData(GL.GL_ELEMENT_ARRAY_BUFFER, indexData.length, indexData.getData(), GL.GL_DYNAMIC_DRAW);
	}

	public function bind()
	{
		GL.glEnableVertexAttribArray(0);
		GL.glEnableVertexAttribArray(1);

		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vertexVbo);
		GL.glVertexAttribOffset(0, 3, GL.GL_FLOAT, false, 32, 0);
		GL.glVertexAttribOffset(1, 2, GL.GL_FLOAT, false, 32, 24);

		GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, indexVbo);
	}
}