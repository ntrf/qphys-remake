/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2019 Anton Nesterov
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package reclaim.console;

import opengl.GL;
import haxe.io.Int32Array;
import haxe.io.ArrayBufferView;

class DebugMesh
{
	public function new()
	{
		bufferData = new ArrayBufferView(24 * 4096);
		indexData = new Int32Array(8192);
	}

	var bufferData : ArrayBufferView;
	var bufferVerts = 0;
	var indexData : Int32Array;
	var indexVerts = 0;

	var vbo : Int = 0;
	var ibo : Int = 0;

	public function clear()
	{
		bufferVerts = 0;
		indexVerts = 0;
	}

	inline public function empty() return indexVerts == 0;

	public function upload()
	{
		if (vbo == 0) {
			var vbos = [0,0];
			GL.glGenBuffers(2, vbos);
			vbo = vbos[0]; ibo = vbos[1];
			GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbo);
			GL.glBufferDataEmpty(GL.GL_ARRAY_BUFFER, bufferData.byteLength, GL.GL_DYNAMIC_DRAW);
			GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, ibo);
			GL.glBufferDataEmpty(GL.GL_ELEMENT_ARRAY_BUFFER, indexData.view.byteLength, GL.GL_DYNAMIC_DRAW);
		} else {
			GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbo);
			GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, ibo);
		}
		GL.glBufferSubData(GL.GL_ARRAY_BUFFER, 0, bufferVerts * 24, bufferData.buffer.getData());
		GL.glBufferSubData(GL.GL_ELEMENT_ARRAY_BUFFER, 0, indexVerts * 4, indexData.view.buffer.getData());
	}

	public function quad(verts : Array<Single>, color : Int)
	{
		var p = bufferData.byteOffset + bufferVerts * 24;
	
		bufferData.buffer.setFloat(p, verts[0]);
		bufferData.buffer.setFloat(p + 4, verts[1]);
		bufferData.buffer.setFloat(p + 8, 0.0);
		bufferData.buffer.setUInt16(p + 16, Std.int(verts[2] * 65535.0));
		bufferData.buffer.setUInt16(p + 18, Std.int(verts[3] * 65535.0));
		bufferData.buffer.setInt32(p + 20, color);
		p += 24;

		bufferData.buffer.setFloat(p, verts[4]);
		bufferData.buffer.setFloat(p + 4, verts[5]);
		bufferData.buffer.setFloat(p + 8, 0.0);
		bufferData.buffer.setUInt16(p + 16, Std.int(verts[6] * 65535.0));
		bufferData.buffer.setUInt16(p + 18, Std.int(verts[7] * 65535.0));
		bufferData.buffer.setInt32(p + 20, color);
		p += 24;

		bufferData.buffer.setFloat(p, verts[8]);
		bufferData.buffer.setFloat(p + 4, verts[9]);
		bufferData.buffer.setFloat(p + 8, 0.0);
		bufferData.buffer.setUInt16(p + 16, Std.int(verts[10] * 65535.0));
		bufferData.buffer.setUInt16(p + 18, Std.int(verts[11] * 65535.0));
		bufferData.buffer.setInt32(p + 20, color);
		p += 24;

		bufferData.buffer.setFloat(p, verts[12]);
		bufferData.buffer.setFloat(p + 4, verts[13]);
		bufferData.buffer.setFloat(p + 8, 0.0);
		bufferData.buffer.setUInt16(p + 16, Std.int(verts[14] * 65535.0));
		bufferData.buffer.setUInt16(p + 18, Std.int(verts[15] * 65535.0));
		bufferData.buffer.setInt32(p + 20, color);
		p += 24;

		var base = bufferVerts;

		p = indexVerts;
		indexData[p++] = base + 0;
		indexData[p++] = base + 1;
		indexData[p++] = base + 2;
		indexData[p++] = base + 2;
		indexData[p++] = base + 1;
		indexData[p++] = base + 3;
		
		indexVerts = p;
		bufferVerts += 4;
	}

	public function draw()
	{
		upload();

		GL.glEnableVertexAttribArray(0);
		GL.glEnableVertexAttribArray(1);
		GL.glEnableVertexAttribArray(2);

		GL.glVertexAttribOffset(0, 4, GL.GL_FLOAT, false, 24, 0);
		GL.glVertexAttribOffset(1, 2, GL.GL_UNSIGNED_SHORT, true, 24, 16);
		GL.glVertexAttribOffset(2, 4, GL.GL_UNSIGNED_BYTE, true, 24, 20);

		GL.glDrawElementsOffset(GL.GL_TRIANGLES, indexVerts, GL.GL_UNSIGNED_INT, 0);
	}
}