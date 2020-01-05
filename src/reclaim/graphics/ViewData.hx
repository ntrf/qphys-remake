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

import haxe.io.Bytes;
import reclaim.math.Mat4;

import opengl.GL;

// This class holds view data for vertex shaders
//@:build(reclaim.macro.MemMappedMacro.buildFields())
class ViewData
{
	public final payloadSize = 256;

	var bytes : Bytes;

	@:align(16)
	public var viewMatrix : Mat4;
	@:align(16)
	public var projMatrix : Mat4;

	public function new()
	{
		//### this should be replaced with some sort of big buffer
		//    and returned to the pool
		bytes = Bytes.alloc(payloadSize);

		viewMatrix = Mat4.fromBytes(bytes, 0);
		projMatrix = Mat4.fromBytes(bytes, 4 * 4 * 4);
	}

	public function configPerspective(view : Mat4, aspect : Float, fov : Float, 
		near : Float, far : Float)
	{
		Mat4.copyFrom(viewMatrix, view);
		Mat4.perspective(projMatrix, fov, aspect, near, far);
	}

	public function upload(buffer : Int)
	{
		GL.glBindBuffer(GL.GL_UNIFORM_BUFFER, buffer);
		GL.glBufferSubData(GL.GL_UNIFORM_BUFFER, 0, payloadSize, bytes.getData());
	}
}
