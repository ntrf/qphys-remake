
import haxe.io.Float32Array;
import haxe.io.Bytes;
import opengl.GL;
import sys.io.File;

class Console
{
	var fontData : haxe.io.Bytes;

	var shader : Shader;

	var fontTexture : Int;

	var bufferData : haxe.io.Float32Array;
	var vbuffer : Int;

	var count = 0;

	public function new() {}

	public function init()
	{
		var font = File.read("../data/ReclaimFont.tga", true);

		font.seek(18, SeekBegin);
		fontData = font.read(256 * 128);

		var textures = [0];
		GL.glGenTextures(1, textures);
		fontTexture = textures[0];
		GL.glBindTexture(GL.GL_TEXTURE_2D, textures[0]);
		GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_NEAREST);
		GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_NEAREST);
		GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_R8, 256, 128, 0, GL.GL_RED, GL.GL_UNSIGNED_BYTE, fontData.getData());
		GL.glBindTexture(GL.GL_TEXTURE_2D, 0);

		shader = new Shader();
		shader.loadShaders("../data/con_vert.glsl", "../data/con_frag.glsl");
		shader.compile();

		bufferData = new Float32Array(2048 * 4 * 8);
		
		var vbos = [0];
		GL.glGenBuffers(1, vbos);
		vbuffer = vbos[0];
		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbuffer);
		GL.glBufferDataEmpty(GL.GL_ARRAY_BUFFER, bufferData.length, GL.GL_DYNAMIC_DRAW);

		putVertex(0, 0,   128, 0.0, 0.0);
		putVertex(1, 0,     0, 0.0, 1.0);
		putVertex(2, 256,   0, 1.0, 1.0);
		putVertex(3, 0,   128, 0.0, 0.0);
		putVertex(4, 256,   0, 1.0, 1.0);
		putVertex(5, 256, 128, 1.0, 0.0);
		count = 6;

		update();
	}

	function putVertex(idx : Int, x : Single, y : Single, tx : Single, ty : Single)
	{
		var off = idx * 8;

		// fill-in some test data
		bufferData[off + 0] = x;
		bufferData[off + 1] = y;
		bufferData[off + 2] = 0.0;
		bufferData[off + 3] = 0.0;
		bufferData[off + 4] = 0.0;
		bufferData[off + 5] = 0.0;
		bufferData[off + 6] = tx;
		bufferData[off + 7] = ty;
	}

	public function update()
	{
		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbuffer);
		GL.glBufferSubData(GL.GL_ARRAY_BUFFER, bufferData.view.byteOffset, count * 32, bufferData.view.buffer.getData());
	}

	public function render(fbWidth : Single, fbHeight : Single)
	{
		if (count <= 0)
			return;

		

		GL.glDisable(GL.GL_DEPTH_TEST);
		GL.glEnable(GL.GL_BLEND);
		GL.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);

		GL.glUseProgram(shader.program);
		GL.glUniform4f(shader.projUni, 2.0 / fbWidth, 2.0 / fbHeight, -1.0, -1.0);
		GL.glUniform1i(shader.mainTexUni, 0);

		GL.glActiveTexture(0);
		GL.glBindTexture(GL.GL_TEXTURE_2D, fontTexture);

		GlState.activateInputs(3);
		
		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbuffer);

		GL.glVertexAttribOffset(0, 3, GL.GL_FLOAT, false, 32, 0);
		GL.glVertexAttribOffset(1, 2, GL.GL_FLOAT, false, 32, 24);
		GL.glVertexAttribOffset(2, 4, GL.GL_FLOAT, false, 32, 12);

		GL.glDrawArrays(GL.GL_TRIANGLES, 0, count);

		GL.glEnable(GL.GL_DEPTH_TEST);
		GL.glDisable(GL.GL_BLEND);
	}
}