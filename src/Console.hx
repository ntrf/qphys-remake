
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

		update();
	}

	function putVertex(idx : Int, x : Int, y : Int, tx : Single, ty : Single)
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

	var lines : Array< String > = [];

	function buildLine(val : String, y : Int)
	{
		var l = val.length;
		var i = 0;
		var x = 5;
		var vi = count;

		var dtx = 3.0 / 64.0;
		var dty = 5.0 / 32.0;

		while (i < l) {
			var ch = val.charCodeAt(i);
			if (ch != null && ch > 0x20 && ch < 0x7f) {
				var tx = ch - 0x20;
				var ty = Std.int(tx / 20);
				tx -= ty * 20;

				// ty * 5 / 32
				var ftx = tx * dtx;
				var fty = ty * dty; 

				putVertex(vi + 0, x, y, ftx, fty);
				putVertex(vi + 1, x, y + 20, ftx, fty + dty);
				putVertex(vi + 2, x + 12, y + 20, ftx + dtx, fty + dty);
				putVertex(vi + 3, x, y, ftx, fty);
				putVertex(vi + 4, x + 12, y + 20, ftx + dtx, fty + dty);
				putVertex(vi + 5, x + 12, y, ftx + dtx, fty);
				vi += 6;
			}
			++i;
			x += 12;
		}

		count = vi;
	}

	public function setLine(i : Int, str : String)
	{
		//### check length
		lines[i] = str;
	}

	public function update()
	{
		count = 0;
		for (i in 0 ... lines.length) {
			buildLine(lines[i], i * 24);
		}

		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbuffer);
		GL.glBufferSubData(GL.GL_ARRAY_BUFFER, bufferData.view.byteOffset, count * 32, bufferData.view.buffer.getData());
	}

	public function render(fbWidth : Single, fbHeight : Single)
	{
		update();

		if (count <= 0)
			return;

		GL.glDisable(GL.GL_DEPTH_TEST);
		GL.glEnable(GL.GL_BLEND);
		GL.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);

		GL.glUseProgram(shader.program);
		GL.glUniform4f(shader.projUni, 2.0 / fbWidth, -2.0 / fbHeight, -1.0, 1.0);
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