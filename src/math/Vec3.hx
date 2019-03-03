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

abstract Vec3(Float32Array) from Float32Array {

	inline public function new(?x:Float=0,?y:Float=0,?z:Float=0) {
		this = new Float32Array(3);
	    this[0] = x;
	    this[1] = y;
	    this[2] = z;
	}

	inline public function set(?x:Float=0,?y:Float=0,?z:Float=0) {
		this[0] = x;
	    this[1] = y;
	    this[2] = z;
	}

	public var x(get,set):Single;
	public var y(get,set):Single;
	public var z(get,set):Single;
	inline function get_x() return this[0];
	inline function get_y() return this[1];
	inline function get_z() return this[2];
	inline function set_x(v:Single) return this[0] = v;
	inline function set_y(v:Single) return this[1] = v;
	inline function set_z(v:Single) return this[2] = v;

	@:arrayAccess
	public inline function getElement(index : Int) {
		return this[index];
	} 
	
	@:arrayAccess 
	public inline function setElement(index : Int, v : Float) : Float {
		this[index] =  v;
		return v;
	}

	/**
	 * Makes a clone of this vector
	 */
	inline public function clone() { return new Vec3(this[0], this[1], this[2]); }

	//TODO check if that makes sense
	/**
	* Transforms the vec3 with a mat4.
	*
	* @param {vec3} out the receiving vector
	* @param {vec3} a the vector to transform
	* @param {mat4} m matrix to transform with
	* @returns {vec3} out
	*/
	inline public function transformMat4(out : Vec3, m : Mat4) : Vec3 {
		var x = this[0];
		var y = this[1];
		var z = this[2];
		out.x = m[0] * x + m[4] * y + m[8] * z + m[12];
		out.y = m[1] * x + m[5] * y + m[9] * z + m[13];
		out.z = m[2] * x + m[6] * y + m[10] * z + m[14];
		return out;
	}

//	public static function fromData()
//	{
//		
//	}

	public function dot(b : Vec3) : Single {
		var d : Single = x * b.x + y * b.y + z * b.z;
		return d;
	}

	public function addIn(b : Vec3) : Vec3 {
		this[0] += b.x;
		this[1] += b.y;
		this[2] += b.z;
		return this;
	}
}