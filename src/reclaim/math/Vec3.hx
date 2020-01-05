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
package reclaim.math;

import haxe.io.Float32Array;

abstract Vec3(Float32Array) {

	inline public function new(x : Single = 0, y : Single = 0, z : Single = 0) {
		this = new Float32Array(3);
	    this[0] = x;
	    this[1] = y;
	    this[2] = z;
	}

	public static function fromBytes(bytes : haxe.io.Bytes, bytePos = 0) : Vec3 {
		return cast Float32Array.fromBytes(bytes, bytePos, 12);
	}

	public var x(get,set) : Single;
	public var y(get,set) : Single;
	public var z(get,set) : Single;
	inline function get_x() return this[0];
	inline function get_y() return this[1];
	inline function get_z() return this[2];
	inline function set_x(v : Single) return this[0] = v;
	inline function set_y(v : Single) return this[1] = v;
	inline function set_z(v : Single) return this[2] = v;

	inline public function clone() return new Vec3(x, y, z);

	@:arrayAccess
	public inline function getElement(index : Int) {
		return this[index];
	} 
	
	@:arrayAccess 
	public inline function setElement(index : Int, v : Single) : Single {
		this[index] =  v;
		return v;
	}

	inline public function set(sx : Single = 0, sy : Single = 0, sz : Single = 0) {
		x = sx;
		y = sy;
		z = sz;
	}

	inline public function copy(v : Vec3) {
		x = v.x;
		y = v.y;
		z = v.z;
	}

	inline public function negate(v : Vec3) {
		x = -v.x;
		y = -v.y;
		z = -v.z;
	}

	inline public function dot(v : Vec3) : Single {
		return x * v.x + y * v.y + z * v.z;
	}

	inline public static function cross(out : Vec3, a : Vec3, b : Vec3) {
		out.x = a.y * b.z - b.y * a.z;
		out.y = a.z * b.x - b.z * b.x;
		out.z = a.x * b.y - a.y * b.x;
	}

	inline public function add(v : Vec3) {
		x = x + v.x;
		y = y + v.y;
		z = z + v.z;
	}

	inline public function mul(v : Vec3) {
		x = x * v.x;
		y = y * v.y;
		z = z * v.z;
	}

	inline public function mulScalar(f : Single) {
		x = x * f;
		y = y * f;
		z = z * f;
	}

	inline public function divScalar(f : Single) {
		x = x / f;
		y = y / f;
		z = z / f;
	}

	inline public function mulAcc(v : Vec3, t : Single) {
		x = x + v.x * t;
		y = y + v.y * t;
		z = z + v.z * t;
	}

	inline public function lepr(v : Vec3, t : Single) {
		var it = 1.0 - t;
		x = x * it + v.x * t;
		y = y * it + v.y * t;
		z = z * it + v.z * t;
	}

	inline public function lengthSqr() : Single {
		return x * x + y * y + z * z;
	}
	
	inline public function length() : Single return Math.sqrt(lengthSqr());

	inline public function distanceSqr(b : Vec3) : Single {
		var dx = x - b.x;
		var dy = y - b.y;
		var dz = z - b.z;
		return dx * dx + dy * dy + dz * dz;
	}

	inline public function distance(b : Vec3) : Single return Math.sqrt(distanceSqr(b));

	public function toString() return '[$x $y $z]';

	// List from twgl:
	// function cross(a, b, dest) : Vec3
	// function divide(a, b, dest) : Vec3
	// function lerp(a, b, t, dest) : Vec3
	// function normalize(v, dest) : Vec3
}
