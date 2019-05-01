import haxe.io.Int32Array;
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

import sys.io.File;
import haxe.io.Bytes;

import opengl.GL;

import math.Vec4;

@:publicFields
class Plane
{
	var normal : math.Vec3;
	var offset : math.Vec3;
}

@:publicFields
class Brush
{
	var planes : Array< Plane >;
	//### size extents
}

/**
 * Storage for map data
 */
class MapData
{
	// Technically the same data can be later fetched in multiple chunks depending on visibility

	var brushes : Array< Brush >;

	var vertexData : Bytes;
	var indexData : Bytes;

	var planeData : Bytes;
	var brushData : Bytes;

	public function new() {}

	public function getPlane(i : Int) {
		return Vec4.fromBytes(planeData, i * 20);
	}

	public function getBrush(i : Int) {
		return Int32Array.fromBytes(brushData, i * 8);
	}

	public var numBrushes : Int;
	public var numPlanes : Int;

	public function load()
	{
		var inp = File.read("../data/vx.bin");

		var vertexDataSize = 169888;
		var indexDataSize = 39252;
		var planeDataSize = 15780;
		var brushDataSize = 560;

		vertexData = inp.read(vertexDataSize);
		indexData = inp.read(indexDataSize);
		planeData = inp.read(planeDataSize);
		brushData = inp.read(brushDataSize);

		numPlanes = Std.int(planeData.length / 20);
		numBrushes = Std.int(brushData.length / 8);
	}

	var glVbo : Int = 0;
	var glIbo : Int = 0;

	public function makegl()
	{
		var vbos = [0, 0];
		GL.glGenBuffers(2, vbos);

		glVbo = vbos[0];
		glIbo = vbos[1];

		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, glVbo);
		GL.glBufferData(GL.GL_ARRAY_BUFFER, vertexData.length, vertexData.getData(), 
			GL.GL_DYNAMIC_DRAW);
		
		GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, glIbo);
		GL.glBufferData(GL.GL_ELEMENT_ARRAY_BUFFER, indexData.length, indexData.getData(),
			GL.GL_DYNAMIC_DRAW);
		
		
	}

	public function bind()
	{
		GlState.activateInputs(2);

		GL.glBindBuffer(GL.GL_ARRAY_BUFFER, glVbo);
		GL.glVertexAttribOffset(0, 3, GL.GL_FLOAT, false, 32, 0);
		GL.glVertexAttribOffset(1, 2, GL.GL_FLOAT, false, 32, 24);

		GL.glBindBuffer(GL.GL_ELEMENT_ARRAY_BUFFER, glIbo);
	}
}

