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
package reclaim.graphics;

import haxe.io.ArrayBufferView;
import opengl.GL;
import haxe.io.Input;
import haxe.io.Bytes;

class MeshPart
{
	public var count : Int;
	public var vertexOffset : Int;
	public var indexOffset : Int;
	
	public var attribs : Array< { off : Int, stride : Int } >;
}

class Mesh
{
	public function new() { }

	var bufferDataVbo : Bytes;
	var bufferDataIbo : Bytes;

	// This is temporary, until i figure out how to import vertex buffer layout
	public function loadAsset3(stream : Input)
	{
		var header = stream.read(12);

		var partCount = stream.readInt32();
		if (partCount != 1)
			throw "Can't load that!";

		var indexSize = stream.readInt32();
		var vertexSize = stream.readInt32();
		
		var parts = [];
		for (i in 0 ... partCount) {
			var indexCount = stream.readInt32();
			var primitive = stream.readInt32();
			var indexOffset = stream.readInt32();
			var vertexOffset = stream.readInt32();

			parts.push({
				count : indexCount,
				prim : primitive,
				indexOffset : indexOffset,
				vertexOffset : vertexOffset
			});
		}

		bufferDataIbo = stream.read(indexSize);
		bufferDataVbo = stream.read(vertexSize);

		vboDesc = {
			start: parts[0].vertexOffset,
			length: vertexSize,
			attribs: [
				{ off: 0, stride : 24 },
				{ off: 12, stride : 24 }
			]
		};
		iboDesc = {
			start: parts[0].vertexOffset,
			length: indexSize,
			count: parts[0].count
		};
	}

	var vbo : Int = 0;
	var ibo : Int = 0;

	var vboDesc : {
		start : Int,
		length : Int,
		attribs : Array< { off : Int, stride : Int } >
	} = null;
	
	var iboDesc : {
		start : Int,
		length : Int,
		count : Int
	} = null;

	public function upload()
	{
		var vbos = [0,0];
		GL.glGenBuffers(2, vbos);
		vbo = vbos[0]; ibo = vbos[1];
		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbo);
		GL.glBufferDataView(GL.GL_ARRAY_BUFFER, ArrayBufferView.fromBytes(bufferDataVbo, vboDesc.start, vboDesc.length), GL.GL_STATIC_DRAW);
		GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, ibo);
		GL.glBufferDataView(GL.GL_ELEMENT_ARRAY_BUFFER, ArrayBufferView.fromBytes(bufferDataIbo, iboDesc.start, iboDesc.length), GL.GL_STATIC_DRAW);
	}

	public function draw()
	{
		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, vbo);
		GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, ibo);

		GL.glEnableVertexAttribArray(0);
		GL.glEnableVertexAttribArray(1);
		GL.glDisableVertexAttribArray(2);

		GL.glVertexAttribOffset(0, 3, GL.GL_FLOAT, false, vboDesc.attribs[0].stride, vboDesc.attribs[0].off);
		GL.glVertexAttribOffset(1, 3, GL.GL_FLOAT, false, vboDesc.attribs[1].stride, vboDesc.attribs[1].off);

		GL.glDrawElementsOffset(GL.GL_TRIANGLES, iboDesc.count, GL.GL_UNSIGNED_INT, 0);
	}
}
