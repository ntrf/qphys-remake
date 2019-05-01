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
package math;

import haxe.io.Float32Array;

abstract Vec4(Float32Array) {

	inline public function new(x : Single = 0, y : Single = 0, z : Single = 0, w : Single = 1.0) {
		this = new Float32Array(4);
	    this[0] = x;
	    this[1] = y;
	    this[2] = z;
	    this[3] = w;
	}
	public static function fromBytes(bytes : haxe.io.Bytes, bytePos = 0) : Vec4 {
		return cast Float32Array.fromBytes(bytes, bytePos, 16);
	}

	public var x(get,set) : Single;
	public var y(get,set) : Single;
	public var z(get,set) : Single;
	public var w(get,set) : Single;
	inline function get_x() return this[0];
	inline function get_y() return this[1];
	inline function get_z() return this[2];
	inline function get_w() return this[3];
	inline function set_x(v : Single) return this[0] = v;
	inline function set_y(v : Single) return this[1] = v;
	inline function set_z(v : Single) return this[2] = v;
	inline function set_w(v : Single) return this[3] = v;

	inline public function clone() return new Vec4(x, y, z, w);

	/**
	* Transforms the vec4 with a mat4.
	*
	* @param {vec4} out the receiving vector
	* @param {vec4} a the vector to transform
	* @param {mat4} m matrix to transform with
	* @returns {vec4} out
	*/
	inline public function transformMat4(out : Vec4, m : Mat4) : Vec4 {
		var x = this[0];
		var y = this[1];
		var z = this[2];
		var w = this[3];
		out.x = m[0] * x + m[4] * y + m[8] * z + m[12] * w;
		out.y = m[1] * x + m[5] * y + m[9] * z + m[13] * w;
		out.z = m[2] * x + m[6] * y + m[10] * z + m[14] * w;
		out.w = m[3] * x + m[7] * y + m[11] * z + m[15] * w;
		return out;
	}

	@:arrayAccess
	public inline function getElement(index : Int) {
		return this[index];
	} 
	
	@:arrayAccess 
	public inline function setElement(index : Int, v : Single) : Single {
		this[index] =  v;
		return v;
	}

	inline public function dot(v : Vec4) : Single {
		return x * v.x + y * v.y + z * v.z + w * v.w;
	}
}